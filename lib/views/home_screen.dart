import 'dart:io';

import 'package:flutter/material.dart';

import '../models/note_file.dart';
import '../services/file_service.dart';
import '../theme/app_theme.dart';
import 'widgets/ai_assistant_panel.dart';
import 'widgets/editor_preview_view.dart';
import 'widgets/knowledge_graph_view.dart';
import 'widgets/resizable_divider.dart';
import 'widgets/sidebar_view.dart';

/// Chế độ hiển thị của vùng làm việc chính
enum CenterViewMode { editor, graph }

/// Màn hình chính phân chia 3 cột có thể co dãn (Resizable Panel M3):
/// [Sidebar] | ResizableDivider | [Editor / Graph View] | ResizableDivider | [AI Panel]
/// Chuẩn đồ họa cao cấp: 3D Layered Shadows, Neon Purple Accents & Glassmorphism
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileService _fileService = const FileService();

  /// Quản lý độ rộng cột bằng ValueNotifier để tối ưu hiệu năng kéo dãn
  final ValueNotifier<double> _sidebarWidth = ValueNotifier<double>(270.0);
  final ValueNotifier<double> _aiPanelWidth = ValueNotifier<double>(350.0);

  CenterViewMode _centerViewMode = CenterViewMode.editor;
  List<NoteFile> _files = [];
  NoteFile? _selectedFile;
  String? _vaultPath;
  bool _isLoadingContent = false;
  bool _isScanning = false;
  bool _showAiPanel = true;

  @override
  void initState() {
    super.initState();
    _checkAndLoadDefaultVault();
  }

  @override
  void dispose() {
    _sidebarWidth.dispose();
    _aiPanelWidth.dispose();
    super.dispose();
  }

  /// Tự động nạp fptu_sample_vault nếu có trong thư mục hiện tại
  Future<void> _checkAndLoadDefaultVault() async {
    try {
      final sampleDir = Directory('fptu_sample_vault');
      if (await sampleDir.exists()) {
        await _loadVaultDirectory(sampleDir.absolute.path);
      }
    } catch (_) {
      // Bỏ qua lỗi nạp ngầm
    }
  }

  /// Mở hộp thoại chọn thư mục Vault
  Future<void> _handleSelectVault() async {
    final path = await _fileService.pickVaultDirectory();
    if (path != null && mounted) {
      await _loadVaultDirectory(path);
    }
  }

  /// Quét và nạp danh sách file .md từ thư mục
  Future<void> _loadVaultDirectory(String directoryPath) async {
    setState(() {
      _isScanning = true;
      _vaultPath = directoryPath;
    });

    final files = await _fileService.scanMarkdownFiles(directoryPath);

    if (!mounted) return;

    // Đọc trước nội dung của tất cả file để phục vụ phân tích Graph Wikilinks
    final List<NoteFile> loadedFiles = [];
    for (final f in files) {
      final content = await _fileService.readNoteContent(f.fullPath);
      loadedFiles.add(f.copyWith(content: content));
    }

    if (!mounted) return;

    setState(() {
      _files = loadedFiles;
      _isScanning = false;
      _selectedFile = null;
    });
  }

  /// Tải nội dung của file được người dùng chọn
  Future<void> _handleSelectFile(NoteFile file) async {
    if (_selectedFile?.fullPath == file.fullPath &&
        _selectedFile?.content.isNotEmpty == true) {
      return;
    }

    setState(() {
      _isLoadingContent = true;
      _selectedFile = file;
    });

    final content = await _fileService.readNoteContent(file.fullPath);

    if (!mounted) return;

    final updated = file.copyWith(content: content);
    setState(() {
      _selectedFile = updated;
      _isLoadingContent = false;
      final index = _files.indexWhere((f) => f.fullPath == file.fullPath);
      if (index != -1) {
        _files[index] = updated;
      }
    });
  }

  /// Lưu file vào đĩa
  Future<void> _handleSaveNote(String newContent) async {
    if (_selectedFile == null) return;
    final success = await _fileService.saveFile(
      _selectedFile!.fullPath,
      newContent,
    );
    if (success) {
      final updated = _selectedFile!.copyWith(
        content: newContent,
        lastModified: DateTime.now(),
      );
      setState(() {
        _selectedFile = updated;
        final index = _files.indexWhere((f) => f.fullPath == updated.fullPath);
        if (index != -1) {
          _files[index] = updated;
        }
      });
    }
  }

  /// Cập nhật nội dung live khi người dùng gõ trong editor
  void _handleContentChanged(String newContent) {
    if (_selectedFile != null && _selectedFile!.content != newContent) {
      final updated = _selectedFile!.copyWith(content: newContent);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedFile = updated;
          });
        }
      });
    }
  }

  /// Tạo một Note mới trong Vault
  Future<void> _handleCreateNote(String fileName) async {
    if (_vaultPath == null) return;
    final newFile = await _fileService.createNewNote(_vaultPath!, fileName);
    if (newFile != null) {
      await _loadVaultDirectory(_vaultPath!);
      final created = _files.firstWhere(
        (f) => f.fullPath == newFile.fullPath,
        orElse: () => newFile,
      );
      await _handleSelectFile(created);
    }
  }

  /// Bắt sự kiện click vào link [[Tên_File]] để tự động mở file
  Future<void> _handleWikiLinkTap(String linkTarget) async {
    final cleanTarget = linkTarget.trim().toLowerCase().replaceAll('.md', '');
    final match = _files.firstWhere(
      (f) => f.fileName.toLowerCase().replaceAll('.md', '') == cleanTarget,
      orElse: () =>
          NoteFile(fileName: '', fullPath: '', lastModified: DateTime.now()),
    );

    if (match.fullPath.isNotEmpty) {
      await _handleSelectFile(match);
      if (_centerViewMode == CenterViewMode.graph) {
        setState(() {
          _centerViewMode = CenterViewMode.editor;
        });
      }
    } else {
      if (!mounted) return;
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không tìm thấy file liên kết: "[[$linkTarget]]" trong Vault hiện tại.',
          ),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Làm mới Vault
  Future<void> _refreshVault() async {
    if (_vaultPath != null) {
      await _loadVaultDirectory(_vaultPath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161522),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 650;
                  final isVeryCompact = constraints.maxWidth < 460;

                  return Row(
                    children: [
                      // Logo & Tiêu đề ứng dụng nổi 3D
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPurple.withOpacity(0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.hub_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isVeryCompact ? 'FPTU SE' : 'FPTU SE Knowledge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (!isCompact) ...[
                        const SizedBox(width: 9),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF232135),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            'Obsidian Second Brain',
                            style: TextStyle(
                              color: Color(0xFFC4B5FD),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Nút chuyển đổi chế độ giữa Editor <-> Graph View nổi 3D
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF100F18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeaderTabButton(
                              mode: CenterViewMode.editor,
                              icon: Icons.article_outlined,
                              label: isCompact ? 'Doc' : 'Tài liệu',
                            ),
                            _buildHeaderTabButton(
                              mode: CenterViewMode.graph,
                              icon: Icons.hub_rounded,
                              label: isCompact ? 'Graph' : 'Graph View',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Nút Thu gọn / Mở rộng AI Panel với Hover Glow
                      _buildAiToggleButton(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      body: Row(
        children: [
          // 1. Sidebar bên trái
          ValueListenableBuilder<double>(
            valueListenable: _sidebarWidth,
            builder: (context, width, child) {
              return SizedBox(width: width, child: child);
            },
            child: SidebarView(
              files: _files,
              selectedFile: _selectedFile,
              vaultPath: _vaultPath,
              isScanning: _isScanning,
              onSelectVault: _handleSelectVault,
              onFileSelected: (file) {
                _handleSelectFile(file);
                if (_centerViewMode == CenterViewMode.graph) {
                  setState(() {
                    _centerViewMode = CenterViewMode.editor;
                  });
                }
              },
              onCreateNote: _handleCreateNote,
              onRefreshVault: _refreshVault,
            ),
          ),

          // Thanh kéo 1 có handle dots
          ResizableDivider(
            onDragDelta: (delta) {
              _sidebarWidth.value = (_sidebarWidth.value + delta).clamp(
                190.0,
                460.0,
              );
            },
          ),

          // 2. Vùng giữa: Editor / Graph View
          Expanded(
            child: _centerViewMode == CenterViewMode.editor
                ? EditorPreviewView(
                    file: _selectedFile,
                    isLoading: _isLoadingContent,
                    onSaveNote: _handleSaveNote,
                    onWikiLinkTap: _handleWikiLinkTap,
                    onContentChanged: _handleContentChanged,
                  )
                : KnowledgeGraphView(
                    files: _files,
                    selectedFile: _selectedFile,
                    onNodeSelected: (file) async {
                      await _handleSelectFile(file);
                      setState(() {
                        _centerViewMode = CenterViewMode.editor;
                      });
                    },
                  ),
          ),

          // Thanh kéo 2 và AI Panel
          if (_showAiPanel) ...[
            ResizableDivider(
              onDragDelta: (delta) {
                _aiPanelWidth.value = (_aiPanelWidth.value - delta).clamp(
                  250.0,
                  560.0,
                );
              },
            ),

            // 3. AI Panel bên phải
            ValueListenableBuilder<double>(
              valueListenable: _aiPanelWidth,
              builder: (context, width, child) {
                return SizedBox(width: width, child: child);
              },
              child: AIAssistantPanel(selectedFile: _selectedFile),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderTabButton({
    required CenterViewMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _centerViewMode == mode;

    return _HoverTabButton(
      isSelected: isSelected,
      icon: icon,
      label: label,
      onTap: () {
        setState(() {
          _centerViewMode = mode;
        });
      },
    );
  }

  Widget _buildAiToggleButton() {
    return _HoverAiToggleButton(
      isActive: _showAiPanel,
      onTap: () {
        setState(() {
          _showAiPanel = !_showAiPanel;
        });
      },
    );
  }
}

/// Nút Tab AppBar có hiệu ứng Hover Glow và Elevation
class _HoverTabButton extends StatefulWidget {
  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HoverTabButton({
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_HoverTabButton> createState() => _HoverTabButtonState();
}

class _HoverTabButtonState extends State<_HoverTabButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            gradient: active ? AppTheme.primaryGradient : null,
            color: active
                ? null
                : (_isHovered
                      ? Colors.white.withOpacity(0.06)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : (_isHovered
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryPurple.withOpacity(0.2),
                            blurRadius: 6,
                          ),
                        ]
                      : null),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 13,
                color: active
                    ? Colors.white
                    : (_isHovered
                          ? Colors.white
                          : Colors.white.withOpacity(0.65)),
              ),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: TextStyle(
                  color: active
                      ? Colors.white
                      : (_isHovered
                            ? Colors.white
                            : Colors.white.withOpacity(0.65)),
                  fontSize: 11.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nút Bật/Tắt AI Panel có hiệu ứng Hover Glow
class _HoverAiToggleButton extends StatefulWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _HoverAiToggleButton({required this.isActive, required this.onTap});

  @override
  State<_HoverAiToggleButton> createState() => _HoverAiToggleButtonState();
}

class _HoverAiToggleButtonState extends State<_HoverAiToggleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.isActive ? 'Thu gọn AI Panel' : 'Mở rộng AI Panel',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? AppTheme.primaryPurple.withOpacity(0.2)
                  : (_isHovered
                        ? Colors.white.withOpacity(0.06)
                        : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.isActive
                    ? AppTheme.primaryPurple.withOpacity(0.5)
                    : Colors.white.withOpacity(0.08),
                width: 1.0,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              widget.isActive
                  ? Icons.auto_awesome_rounded
                  : Icons.auto_awesome_outlined,
              size: 16,
              color: widget.isActive
                  ? const Color(0xFFC4B5FD)
                  : Colors.white.withOpacity(0.65),
            ),
          ),
        ),
      ),
    );
  }
}
