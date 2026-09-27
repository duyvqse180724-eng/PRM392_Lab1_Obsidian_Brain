import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path/path.dart' as p;

import '../../models/note_file.dart';
import '../../theme/app_theme.dart';

/// Chế độ hiển thị của Editor
enum ViewMode { preview, edit }

/// Vùng giữa: Editor (Chỉnh sửa) & Preview (Xem trước Markdown M3)
/// Chuẩn đồ họa cao cấp:
/// - Header Toolbar thẻ nổi 3D với viền phát sáng nhẹ góc trên
/// - Nút "Lưu Note" dải màu chuyển sắc 3D (#7C3AED -> #9333EA) kết hợp hover glow neon
/// - Hỗ trợ hiển thị hình ảnh đầy đủ (Local file & Internet) bọc trong ClipRRect + BoxShadow
class EditorPreviewView extends StatefulWidget {
  final NoteFile? file;
  final bool isLoading;
  final Future<void> Function(String newContent) onSaveNote;
  final ValueChanged<String> onWikiLinkTap;

  /// Callback thời gian thực khi người dùng gõ trong editor
  final ValueChanged<String>? onContentChanged;

  const EditorPreviewView({
    super.key,
    required this.file,
    required this.isLoading,
    required this.onSaveNote,
    required this.onWikiLinkTap,
    this.onContentChanged,
  });

  @override
  State<EditorPreviewView> createState() => _EditorPreviewViewState();
}

class _EditorPreviewViewState extends State<EditorPreviewView> {
  ViewMode _viewMode = ViewMode.preview;
  late TextEditingController _textController;
  bool _isSaving = false;
  String? _currentFilePath;

  @override
  void initState() {
    super.initState();
    _currentFilePath = widget.file?.fullPath;
    _textController = TextEditingController(text: widget.file?.content ?? '');
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.onContentChanged?.call(_textController.text);
  }

  @override
  void didUpdateWidget(covariant EditorPreviewView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.file?.fullPath != _currentFilePath) {
      _currentFilePath = widget.file?.fullPath;
      _textController.removeListener(_onTextChanged);
      _textController.text = widget.file?.content ?? '';
      _textController.addListener(_onTextChanged);
    } else if (oldWidget.file?.content != widget.file?.content &&
        _viewMode == ViewMode.preview) {
      _textController.removeListener(_onTextChanged);
      _textController.text = widget.file?.content ?? '';
      _textController.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  /// Xử lý lưu file vào đĩa
  Future<void> _handleSave() async {
    if (widget.file == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    await widget.onSaveNote(_textController.text);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF16A34A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Đã lưu file "${widget.file!.fileName}" thành công!',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B1A28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: const Color(0xFF16A34A).withOpacity(0.5),
            width: 1.0,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Chuẩn hóa cú pháp [[Tên_File]] của Obsidian thành Markdown Link
  String _processObsidianWikiLinks(String markdown) {
    final wikiLinkRegex = RegExp(r'\[\[(.*?)\]\]');
    return markdown.replaceAllMapped(wikiLinkRegex, (match) {
      final target = match.group(1) ?? '';
      return '[$target](obsidian://$target)';
    });
  }

  /// Widget fallback khi không load được hình ảnh
  Widget _buildImageErrorWidget(
    String label, {
    required bool isNetwork,
    String? notFoundPath,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1B28),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isNetwork
                  ? Icons.broken_image_outlined
                  : Icons.image_not_supported_outlined,
              size: 20,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.isNotEmpty ? label : 'Hình ảnh',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isNetwork
                      ? 'Không thể tải ảnh từ mạng internet'
                      : (notFoundPath != null
                            ? 'Không tìm thấy: ${p.basename(notFoundPath)}'
                            : 'Tệp ảnh cục bộ không tồn tại'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 10.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Image builder tùy biến: hỗ trợ cả Local File & Online URL
  Widget _buildMarkdownImage(Uri uri, String? title, String? alt) {
    Widget imageWidget;
    final uriString = uri.toString();

    if (uri.scheme == 'http' || uri.scheme == 'https') {
      // 1. Online Image
      imageWidget = Image.network(
        uriString,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 160,
            color: const Color(0xFF191826),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đang tải hình ảnh...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorWidget(alt ?? uriString, isNetwork: true);
        },
      );
    } else {
      // 2. Local File Image
      File? localImageFile;
      final rawPath = Uri.decodeFull(
        uri.path.isNotEmpty ? uri.path : uriString,
      );

      if (p.isAbsolute(rawPath)) {
        localImageFile = File(rawPath);
      } else if (widget.file != null) {
        final noteDir = p.dirname(widget.file!.fullPath);
        final resolved = p.join(noteDir, rawPath);
        localImageFile = File(resolved);
        if (!localImageFile.existsSync()) {
          // Thử tìm ở thư mục cha (vault root)
          final parentResolved = p.join(p.dirname(noteDir), rawPath);
          if (File(parentResolved).existsSync()) {
            localImageFile = File(parentResolved);
          }
        }
      }

      if (localImageFile != null && localImageFile.existsSync()) {
        imageWidget = Image.file(
          localImageFile,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageErrorWidget(alt ?? rawPath, isNetwork: false);
          },
        );
      } else {
        imageWidget = _buildImageErrorWidget(
          alt ?? rawPath,
          isNetwork: false,
          notFoundPath: localImageFile?.path ?? rawPath,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: AppTheme.primaryPurple.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageWidget,
            ),
          ),
          if (title != null && title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6.0, left: 4.0),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.isLoading) {
      return Container(
        color: const Color(0xFF100F17),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1926),
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.panel3dShadow,
                  border: AppTheme.highlightBorder,
                ),
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Đang nạp tập tin từ ổ đĩa...',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.file == null) {
      return Container(
        color: const Color(0xFF100F17),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xFF171622),
              borderRadius: BorderRadius.circular(18),
              border: AppTheme.highlightBorder,
              boxShadow: AppTheme.panel3dShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'FPTU Obsidian Second Brain',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chọn hoặc tạo ghi chú từ cột bên trái để bắt đầu đọc và chỉnh sửa.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentFile = widget.file!;
    final processedMarkdown = _processObsidianWikiLinks(
      _textController.text.isEmpty ? currentFile.content : _textController.text,
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            _handleSave,
      },
      child: Focus(
        autofocus: true,
        child: Container(
          color: const Color(0xFF100F17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Toolbar Thẻ nổi 3D
              Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1926),
                  borderRadius: BorderRadius.circular(14),
                  border: AppTheme.highlightBorder,
                  boxShadow: AppTheme.cardSoftShadow,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 530;
                    final isVeryCompact = constraints.maxWidth < 390;

                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPurple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.article_rounded,
                            size: 16,
                            color: Color(0xFFC4B5FD),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentFile.fileName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (!isVeryCompact) ...[
                                const SizedBox(height: 1),
                                Text(
                                  currentFile.fullPath,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 9.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Toggle Chế độ 3D giữa Xem trước (Preview) và Chỉnh sửa (Edit)
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13121C),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildModeTabItem(
                                mode: ViewMode.preview,
                                icon: Icons.visibility_outlined,
                                label: isVeryCompact
                                    ? ''
                                    : (isCompact ? 'Xem' : 'Xem trước'),
                              ),
                              _buildModeTabItem(
                                mode: ViewMode.edit,
                                icon: Icons.edit_note_rounded,
                                label: isVeryCompact
                                    ? ''
                                    : (isCompact ? 'Sửa' : 'Chỉnh sửa'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Nút "Lưu Note" dải màu chuyển sắc 3D (#7C3AED -> #9333EA)
                        GradientButton3D(
                          onPressed: _isSaving ? null : _handleSave,
                          tooltip: 'Lưu Note (Ctrl+S)',
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 13,
                                  height: 13,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.save_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                          label: isVeryCompact
                              ? null
                              : Text(
                                  _isSaving
                                      ? 'Lưu...'
                                      : (isCompact
                                            ? 'Lưu'
                                            : 'Lưu Note (Ctrl+S)'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isVeryCompact
                                ? 10
                                : (isCompact ? 10 : 13),
                            vertical: 8,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Thân hiển thị: Editor hoặc Markdown Preview
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14131E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 1.0,
                    ),
                    boxShadow: AppTheme.panel3dShadow,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _viewMode == ViewMode.edit
                        ? Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: TextField(
                              controller: _textController,
                              maxLines: null,
                              expands: true,
                              style: const TextStyle(
                                color: Color(0xFFF1F5F9),
                                fontSize: 13.5,
                                fontFamily: 'Consolas',
                                height: 1.55,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Nhập nội dung Markdown tại đây (hỗ trợ ![](), [[]], code blocks...)...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),
                          )
                        : SelectionArea(
                            child: Markdown(
                              data: processedMarkdown.isEmpty
                                  ? '_Ghi chú hiện đang trống._'
                                  : processedMarkdown,
                              selectable: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 22,
                              ),
                              imageBuilder: _buildMarkdownImage,
                              onTapLink: (text, href, title) {
                                if (href != null &&
                                    href.startsWith('obsidian://')) {
                                  final target = href.substring(
                                    'obsidian://'.length,
                                  );
                                  widget.onWikiLinkTap(target);
                                }
                              },
                              styleSheet: _buildPremiumMarkdownStyle(context),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTabItem({
    required ViewMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _viewMode == mode;

    return _HoverTabItem(
      isSelected: isSelected,
      icon: icon,
      label: label,
      onTap: () {
        setState(() {
          _viewMode = mode;
        });
      },
    );
  }

  MarkdownStyleSheet _buildPremiumMarkdownStyle(BuildContext context) {
    final theme = Theme.of(context);
    final base = MarkdownStyleSheet.fromTheme(theme);

    return base.copyWith(
      p: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 14, height: 1.65),
      h1: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.35,
        letterSpacing: 0.3,
      ),
      h2: const TextStyle(
        color: Color(0xFFF1F5F9),
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.35,
      ),
      h3: const TextStyle(
        color: Color(0xFFE2E8F0),
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      code: const TextStyle(
        color: Color(0xFFA78BFA),
        backgroundColor: Color(0xFF232135),
        fontFamily: 'Consolas',
        fontSize: 12.5,
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF191826),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      codeblockPadding: const EdgeInsets.all(14),
      blockquote: TextStyle(
        color: Colors.white.withOpacity(0.75),
        fontStyle: FontStyle.italic,
        fontSize: 13.5,
        height: 1.5,
      ),
      blockquoteDecoration: BoxDecoration(
        color: const Color(0xFF1C1A2B),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: AppTheme.primaryPurple, width: 3.5),
        ),
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      tableBorder: TableBorder.all(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      ),
      tableHead: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      tableBody: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12.5),
      tablePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      listBullet: const TextStyle(
        color: AppTheme.primaryPurple,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      a: const TextStyle(
        color: Color(0xFFA78BFA),
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Nút Tab chọn với hiệu ứng 3D và Hover Glow
class _HoverTabItem extends StatefulWidget {
  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HoverTabItem({
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_HoverTabItem> createState() => _HoverTabItemState();
}

class _HoverTabItemState extends State<_HoverTabItem> {
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
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                      color: AppTheme.primaryPurple.withOpacity(0.35),
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
              if (widget.label.isNotEmpty) ...[
                const SizedBox(width: 5),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: active
                        ? Colors.white
                        : (_isHovered
                              ? Colors.white
                              : Colors.white.withOpacity(0.65)),
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
