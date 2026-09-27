import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Thanh phân cách giữa các cột panel có thể kéo giãn (Resizable Divider M3)
///
/// Hỗ trợ:
/// - Con trỏ chuột [SystemMouseCursors.resizeColumn] khi hover
/// - Kéo ngang để thay đổi kích thước Sidebar hoặc AI Panel mượt mà
/// - Dải 3 chấm nắm tay cầm (Handle dots) ở giữa giúp định vị tay kéo
/// - Đổi màu highlight tím neon (#7C3AED) và glow khi hover hoặc đang kéo
class ResizableDivider extends StatefulWidget {
  /// Callback nhận delta pixels khi người dùng kéo ngang
  final ValueChanged<double> onDragDelta;

  const ResizableDivider({super.key, required this.onDragDelta});

  @override
  State<ResizableDivider> createState() => _ResizableDividerState();
}

class _ResizableDividerState extends State<ResizableDivider> {
  bool _isHovered = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = _isHovered || _isDragging;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => setState(() => _isDragging = true),
        onHorizontalDragUpdate: (details) =>
            widget.onDragDelta(details.delta.dx),
        onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
        onHorizontalDragCancel: () => setState(() => _isDragging = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 7.0,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryPurple
                : colorScheme.surfaceContainerHighest.withOpacity(0.4),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2.5),
                  width: 3.2,
                  height: 3.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.8),
                              blurRadius: 3,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
