import 'package:flutter/material.dart';

/// Design System chuẩn đồ họa cao cấp cho FPTU Obsidian Second Brain:
/// - Chiều sâu 3D (Layered Shadows)
/// - Viền phát sáng nhẹ góc trên (Inner glow / Highlight border)
/// - Neon Purple Glow & Gradients
/// - Thẻ nổi Glassmorphism mờ
class AppTheme {
  AppTheme._();

  // Color Palette
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color secondaryPurple = Color(0xFF9333EA);
  static const Color deepPurple = Color(0xFF6D28D9);
  static const Color darkBg = Color(0xFF111019);
  static const Color surfaceCard = Color(0xFF1A1926);
  static const Color glassAiBubble = Color(0xCC262626);

  // 3D Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient userBubbleGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiAvatarGradient = LinearGradient(
    colors: [Color(0xFF9333EA), Color(0xFF7C3AED), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Layered BoxShadows
  /// Đổ bóng đa tầng cho Card, Panel, Sidebar:
  /// - Bóng tối sâu phía dưới: offset (0, 8), blur 16
  /// - Tán sáng mờ nhẹ xung quanh tạo độ nổi 3D
  static List<BoxShadow> get panel3dShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 16,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: primaryPurple.withOpacity(0.04),
      blurRadius: 24,
      offset: const Offset(0, 2),
      spreadRadius: 1,
    ),
  ];

  /// Bóng đổ nhẹ cho Card con bên trong
  static List<BoxShadow> get cardSoftShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Bóng đổ phát sáng tím neon khi hover nút bấm hoặc tab
  static List<BoxShadow> get neonGlowShadow => [
    BoxShadow(
      color: primaryPurple.withOpacity(0.40),
      blurRadius: 16,
      spreadRadius: 1,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Viền phát sáng nhẹ góc trên (Inner glow / Highlight border)
  static Border get highlightBorder =>
      Border.all(color: Colors.white.withOpacity(0.08), width: 1.2);

  /// Viền sáng màu bạc mỏng cho thẻ AI
  static Border get silverBorder =>
      Border.all(color: Colors.white.withOpacity(0.12), width: 1.0);

  /// Viền vi tế khi hover
  static Border get hoverPurpleBorder =>
      Border.all(color: primaryPurple.withOpacity(0.6), width: 1.2);
}

/// Nút bấm 3D cao cấp hỗ trợ:
/// - Dải màu chuyển sắc [LinearGradient] từ #7C3AED sang #9333EA
/// - Bo góc 12
/// - Hiệu ứng Hover: Bung bóng đổ phát sáng tím neon (#7C3AED.withOpacity(0.4))
/// - Click feedback mượt mà
class GradientButton3D extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Widget? label;
  final EdgeInsetsGeometry? padding;
  final bool isSecondary;
  final String? tooltip;

  const GradientButton3D({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.padding,
    this.isSecondary = false,
    this.tooltip,
  });

  @override
  State<GradientButton3D> createState() => _GradientButton3DState();
}

class _GradientButton3DState extends State<GradientButton3D> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;

    final decoration = BoxDecoration(
      gradient: isEnabled
          ? (widget.isSecondary
                ? const LinearGradient(
                    colors: [Color(0xFF2E2445), Color(0xFF3B2B5C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : AppTheme.primaryGradient)
          : LinearGradient(
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.08),
              ],
            ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: _isHovered && isEnabled
            ? AppTheme.primaryPurple.withOpacity(0.8)
            : Colors.white.withOpacity(0.12),
        width: 1.2,
      ),
      boxShadow: !isEnabled
          ? null
          : (_isHovered
                ? AppTheme.neonGlowShadow
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]),
    );

    Widget buttonContent = AnimatedScale(
      scale: _isPressed ? 0.97 : (_isHovered ? 1.02 : 1.0),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            widget.padding ??
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: decoration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.icon,
            if (widget.label != null) ...[
              const SizedBox(width: 7),
              Flexible(child: widget.label!),
            ],
          ],
        ),
      ),
    );

    if (widget.tooltip != null) {
      buttonContent = Tooltip(message: widget.tooltip!, child: buttonContent);
    }

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: buttonContent,
      ),
    );
  }
}
