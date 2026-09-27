import 'package:flutter/material.dart';

import '../../models/note_file.dart';
import '../../theme/app_theme.dart';

/// Cột trái: Mở Vault, Tạo note mới, Tìm kiếm và Danh sách file Markdown
/// Thiết kế chuẩn đồ họa cao cấp: 3D Layered Shadows, Gradient Buttons & Neon Glow
class SidebarView extends StatefulWidget {
  final List<NoteFile> files;
  final NoteFile? selectedFile;
  final String? vaultPath;
  final bool isScanning;
  final VoidCallback onSelectVault;
  final ValueChanged<NoteFile> onFileSelected;
  final Future<void> Function(String fileName) onCreateNote;
  final VoidCallback onRefreshVault;

  const SidebarView({
    super.key,
    required this.files,
    required this.selectedFile,
    required this.vaultPath,
    required this.isScanning,
    required this.onSelectVault,
    required this.onFileSelected,
    required this.onCreateNote,
    required this.onRefreshVault,
  });

  @override
  State<SidebarView> createState() => _SidebarViewState();
}

class _SidebarViewState extends State<SidebarView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<NoteFile> get _filteredFiles {
    if (_searchQuery.isEmpty) {
      return widget.files;
    }
    return widget.files.where((file) {
      return file.fileName.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  /// Mở hộp thoại nhập tên note mới với giao diện Card 3D
  Future<void> _showCreateNoteDialog() async {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.vaultPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Vui lòng mở một thư mục Vault trước khi tạo ghi chú mới.',
          ),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1D2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.12), width: 1.2),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.note_add_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tạo Ghi Chú Mới',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nhập tên file ghi chú (hệ thống sẽ tự động thêm đuôi .md):',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameController,
                autofocus: true,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Ví dụ: PRM392_Flutter_Desktop',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF14131D),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryPurple,
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    Navigator.of(dialogCtx).pop(val.trim());
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                'Hủy',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            GradientButton3D(
              onPressed: () {
                final text = nameController.text.trim();
                if (text.isNotEmpty) {
                  Navigator.of(dialogCtx).pop(text);
                }
              },
              icon: const Icon(
                Icons.check_rounded,
                size: 14,
                color: Colors.white,
              ),
              label: const Text(
                'Tạo Note',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ],
        );
      },
    );

    nameController.dispose();

    if (result != null && result.isNotEmpty) {
      await widget.onCreateNote(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filtered = _filteredFiles;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13121C),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.06), width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card 3D: Nút Mở Vault (Gradient 3D) & Nút Tạo Note (3D)
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1926),
              borderRadius: BorderRadius.circular(14),
              border: AppTheme.highlightBorder,
              boxShadow: AppTheme.cardSoftShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    // Nút "Mở Vault" dải màu chuyển sắc 3D (#7C3AED -> #9333EA)
                    Expanded(
                      child: GradientButton3D(
                        onPressed: widget.isScanning
                            ? null
                            : widget.onSelectVault,
                        icon: widget.isScanning
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.folder_open_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                        label: Text(
                          widget.isScanning ? 'Đang quét...' : 'Mở Vault',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Nút "Tạo Note" 3D Tonal Button có Hover Glow
                    _buildIconButton3D(
                      icon: Icons.note_add_rounded,
                      tooltip: 'Tạo Note mới',
                      onTap: _showCreateNoteDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Card thông tin Vault hiện tại
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14131F),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.storage_rounded,
                          size: 13,
                          color: Color(0xFFA78BFA),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.vaultPath != null
                              ? widget.vaultPath!.split(RegExp(r'[\\/]')).last
                              : 'Chưa mở Vault',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.vaultPath != null)
                        _buildSmallIconButton(
                          icon: Icons.refresh_rounded,
                          tooltip: 'Làm mới Vault',
                          onTap: widget.onRefreshVault,
                        ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.primaryPurple.withOpacity(0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '${widget.files.length} notes',
                          style: const TextStyle(
                            color: Color(0xFFC4B5FD),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Thanh Search tìm kiếm file theo từ khóa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFF191826),
                  hintText: 'Tìm kiếm note (PRM, SWP, PRN...)',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontSize: 11.5,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 15,
                    color: AppTheme.primaryPurple.withOpacity(0.8),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.07),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppTheme.primaryPurple.withOpacity(0.9),
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Quick Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTagChip('Tất cả', ''),
                  const SizedBox(width: 5),
                  _buildTagChip('PRM', 'prm'),
                  const SizedBox(width: 5),
                  _buildTagChip('SWP', 'swp'),
                  const SizedBox(width: 5),
                  _buildTagChip('PRN', 'prn'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 4),
          Divider(height: 1, color: Colors.white.withOpacity(0.06)),

          // Danh sách file Markdown với hiệu ứng Thẻ nổi 3D khi chọn
          Expanded(
            child: widget.files.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1926),
                              shape: BoxShape.circle,
                              boxShadow: AppTheme.cardSoftShadow,
                              border: AppTheme.highlightBorder,
                            ),
                            child: Icon(
                              Icons.folder_special_outlined,
                              size: 32,
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa mở thư mục Vault',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nhấn nút "Mở Vault" phía trên để nạp tài liệu.',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : filtered.isEmpty
                ? Center(
                    child: Text(
                      'Không có file khớp "$_searchQuery"',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final file = filtered[index];
                      final isSelected =
                          widget.selectedFile?.fullPath == file.fullPath;

                      return _FileListItem(
                        file: file,
                        isSelected: isSelected,
                        onTap: () => widget.onFileSelected(file),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton3D({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return _HoverElevationButton(
      tooltip: tooltip,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFF262438),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 17, color: const Color(0xFFE2E8F0)),
      ),
    );
  }

  Widget _buildSmallIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(icon, size: 15, color: Colors.white.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget _buildTagChip(String label, String keyword) {
    final isSelected =
        (_searchQuery.isEmpty && keyword.isEmpty) ||
        (_searchQuery == keyword && keyword.isNotEmpty);

    return _HoverChip(
      label: label,
      isSelected: isSelected,
      onTap: () => _searchController.text = keyword,
    );
  }
}

/// Nút bọc có hiệu ứng hover nổi và glow nhẹ
class _HoverElevationButton extends StatefulWidget {
  final Widget child;
  final String tooltip;
  final VoidCallback onTap;

  const _HoverElevationButton({
    required this.child,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_HoverElevationButton> createState() => _HoverElevationButtonState();
}

class _HoverElevationButtonState extends State<_HoverElevationButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isHovered ? AppTheme.neonGlowShadow : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Chip lọc nhanh có hiệu ứng hover & selected 3D
class _HoverChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _HoverChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_HoverChip> createState() => _HoverChipState();
}

class _HoverChipState extends State<_HoverChip> {
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: active ? AppTheme.primaryGradient : null,
            color: active
                ? null
                : (_isHovered
                      ? const Color(0xFF262438)
                      : const Color(0xFF1A1926)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? AppTheme.primaryPurple
                  : (_isHovered
                        ? AppTheme.primaryPurple.withOpacity(0.5)
                        : Colors.white.withOpacity(0.08)),
              width: 1.0,
            ),
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
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: active
                  ? Colors.white
                  : (_isHovered ? Colors.white : Colors.white.withOpacity(0.7)),
              fontSize: 10.5,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Item file có hiệu ứng thẻ nổi 3D đa tầng khi active hoặc hover
class _FileListItem extends StatefulWidget {
  final NoteFile file;
  final bool isSelected;
  final VoidCallback onTap;

  const _FileListItem({
    required this.file,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FileListItem> createState() => _FileListItemState();
}

class _FileListItemState extends State<_FileListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;

    final decoration = isSelected
        ? BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E204A), Color(0xFF211A35)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.primaryPurple.withOpacity(0.7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppTheme.primaryPurple.withOpacity(0.25),
                blurRadius: 14,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          )
        : BoxDecoration(
            color: _isHovered ? const Color(0xFF1E1D2D) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
              width: 1.0,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: decoration,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryPurple.withOpacity(0.3)
                      : (_isHovered
                            ? Colors.white.withOpacity(0.06)
                            : Colors.transparent),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 15,
                  color: isSelected
                      ? const Color(0xFFC4B5FD)
                      : (_isHovered
                            ? Colors.white
                            : Colors.white.withOpacity(0.6)),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.file.fileName,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (_isHovered
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.85)),
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.file.formattedDate,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFFA78BFA)
                            : Colors.white.withOpacity(0.4),
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: Color(0xFFA78BFA),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
