import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../models/graph_data.dart';
import '../../models/note_file.dart';
import '../../services/graph_service.dart';
import '../../theme/app_theme.dart';

/// Màn hình tương tác đồ thị tri thức (Interactive Knowledge Graph View - M3)
class KnowledgeGraphView extends StatefulWidget {
  final List<NoteFile> files;
  final NoteFile? selectedFile;
  final ValueChanged<NoteFile> onNodeSelected;

  const KnowledgeGraphView({
    super.key,
    required this.files,
    required this.selectedFile,
    required this.onNodeSelected,
  });

  @override
  State<KnowledgeGraphView> createState() => _KnowledgeGraphViewState();
}

class _KnowledgeGraphViewState extends State<KnowledgeGraphView>
    with SingleTickerProviderStateMixin {
  final GraphService _graphService = const GraphService();
  late AnimationController _animationController;
  final TransformationController _transformController =
      TransformationController();

  GraphData _graphData = GraphData.empty;
  GraphNode? _draggedNode;
  GraphNode? _hoveredNode;
  final Size _canvasSize = const Size(2400, 1700);
  double _linkDistance = 280.0;
  Size _lastViewportSize = Size.zero;
  Offset? _pointerDownPos;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_simulatePhysics);

    _buildGraphData();
  }

  @override
  void didUpdateWidget(covariant KnowledgeGraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.files != widget.files) {
      _buildGraphData();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _buildGraphData() {
    _graphData = _graphService.buildGraph(
      widget.files,
      canvasSize: _canvasSize,
    );
    if (_graphData.nodes.isNotEmpty) {
      _animationController.repeat();
    }
  }

  /// Thuật toán mô phỏng vật lý Force-Directed Graph (Lực đẩy Coulomb + Lực kéo Hooke)
  void _simulatePhysics() {
    if (_graphData.nodes.isEmpty) return;

    final nodes = _graphData.nodes;
    final edges = _graphData.edges;
    final center = Offset(_canvasSize.width / 2, _canvasSize.height / 2);

    const kRepulsion = 28000.0;
    const kSpring = 0.040;
    final restLength = _linkDistance;
    const kCenterGravity = 0.007;
    const damping = 0.88;

    // 1. Lực đẩy giữa tất cả các cặp node (Coulomb Repulsion)
    for (var i = 0; i < nodes.length; i++) {
      for (var j = i + 1; j < nodes.length; j++) {
        final nodeA = nodes[i];
        final nodeB = nodes[j];

        final delta = nodeA.position - nodeB.position;
        final distance = math.max(delta.distance, 15.0);
        final forceMagnitude = kRepulsion / (distance * distance);
        final force = (delta / distance) * forceMagnitude;

        if (nodeA != _draggedNode) nodeA.velocity += force;
        if (nodeB != _draggedNode) nodeB.velocity -= force;
      }
    }

    // 2. Lực kéo lò xo giữa các node có liên kết (Spring Hooke)
    final nodeMap = {for (final n in nodes) n.id: n};

    for (final edge in edges) {
      final nodeA = nodeMap[edge.sourceId];
      final nodeB = nodeMap[edge.targetId];

      if (nodeA != null && nodeB != null) {
        final delta = nodeB.position - nodeA.position;
        final distance = math.max(delta.distance, 1.0);
        final displacement = distance - restLength;
        final springForce = (delta / distance) * (displacement * kSpring);

        if (nodeA != _draggedNode) nodeA.velocity += springForce;
        if (nodeB != _draggedNode) nodeB.velocity -= springForce;
      }
    }

    // 3. Lực hướng tâm kéo các node về giữa canvas và áp dụng vận tốc
    var totalKineticEnergy = 0.0;

    for (final node in nodes) {
      if (node == _draggedNode) continue;

      final toCenter = center - node.position;
      node.velocity += toCenter * kCenterGravity;
      node.velocity *= damping;

      node.position += node.velocity;

      // Giới hạn trong viền canvas
      node.position = Offset(
        node.position.dx.clamp(80.0, _canvasSize.width - 80.0),
        node.position.dy.clamp(80.0, _canvasSize.height - 80.0),
      );

      totalKineticEnergy += node.velocity.distanceSquared;
    }

    // Nếu toàn bộ hệ thống đã đạt trạng thái cân bằng tĩnh thì tạm dừng Ticker
    if (totalKineticEnergy < 0.12 && _draggedNode == null) {
      _animationController.stop();
    }

    setState(() {});
  }

  /// Tìm node dưới tọa độ con trỏ chuột
  GraphNode? _findNodeAt(Offset localPosition) {
    final scenePoint = _transformController.toScene(localPosition);

    for (final node in _graphData.nodes) {
      final distance = (node.position - scenePoint).distance;
      if (distance <= node.radius + 12) {
        return node;
      }
    }
    return null;
  }

  /// Phóng to / Thu nhỏ xoay quanh điểm trỏ chuột focalPoint
  void _zoomAt(Offset focalPoint, double scaleDelta) {
    final matrix = _transformController.value.clone();
    final currentScale = matrix.getMaxScaleOnAxis();
    final targetScale = (currentScale * scaleDelta).clamp(0.25, 3.5);
    final effectiveDelta = targetScale / currentScale;
    if ((effectiveDelta - 1.0).abs() < 0.001) return;

    final translation = Matrix4.translationValues(
      focalPoint.dx,
      focalPoint.dy,
      0,
    );
    final scale = Matrix4.diagonal3Values(effectiveDelta, effectiveDelta, 1.0);
    final invTranslation = Matrix4.translationValues(
      -focalPoint.dx,
      -focalPoint.dy,
      0,
    );

    _transformController.value = translation * scale * invTranslation * matrix;
    setState(() {});
  }

  /// Đặt lại zoom và căn giữa toàn bộ đồ thị theo kích thước màn hình
  void _resetZoom([Size? viewportSize]) {
    final vp = viewportSize ?? _lastViewportSize;
    if (vp.isEmpty) {
      _transformController.value = Matrix4.identity();
      return;
    }

    final scaleX = vp.width / _canvasSize.width;
    final scaleY = vp.height / _canvasSize.height;
    final scale = math.min(scaleX, scaleY).clamp(0.20, 1.0);

    final tx = (vp.width - _canvasSize.width * scale) / 2;
    final ty = (vp.height - _canvasSize.height * scale) / 2;

    final matrix = Matrix4.diagonal3Values(scale, scale, 1.0);
    matrix.setTranslationRaw(tx, ty, 0);

    _transformController.value = matrix;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.files.isEmpty) {
      return ColoredBox(
        color: colorScheme.surface,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hub_outlined,
                size: 54,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 14),
              Text(
                'Chưa có dữ liệu đồ thị tri thức',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Mở thư mục Vault chứa các file .md để hiển thị mạng lưới liên kết.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final activeFile = widget.selectedFile;

    return LayoutBuilder(
      builder: (context, constraints) {
        final currentVp = Size(constraints.maxWidth, constraints.maxHeight);
        if (_lastViewportSize == Size.zero &&
            currentVp.width > 0 &&
            currentVp.height > 0) {
          _lastViewportSize = currentVp;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _resetZoom(currentVp);
          });
        } else {
          _lastViewportSize = currentVp;
        }

        return Stack(
          children: [
            // Khung Canvas đồ thị: Hỗ trợ Cuộn chuột Zoom + Pan nền + Drag Node
            ColoredBox(
              color: colorScheme.surface,
              child: Listener(
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent) {
                    final zoomFactor = pointerSignal.scrollDelta.dy < 0
                        ? 1.15
                        : 0.87;
                    _zoomAt(pointerSignal.localPosition, zoomFactor);
                  }
                },
                onPointerDown: (event) {
                  _pointerDownPos = event.localPosition;
                  final hitNode = _findNodeAt(event.localPosition);
                  if (hitNode != null) {
                    setState(() {
                      _draggedNode = hitNode;
                    });
                    if (!_animationController.isAnimating) {
                      _animationController.repeat();
                    }
                  }
                },
                onPointerMove: (event) {
                  if (_draggedNode != null) {
                    final scenePoint = _transformController.toScene(
                      event.localPosition,
                    );
                    setState(() {
                      _draggedNode!.position = scenePoint;
                      _draggedNode!.velocity = Offset.zero;
                    });
                  }
                },
                onPointerUp: (event) {
                  if (_draggedNode != null) {
                    final moved =
                        (event.localPosition -
                                (_pointerDownPos ?? event.localPosition))
                            .distance;
                    if (moved < 8) {
                      widget.onNodeSelected(_draggedNode!.file);
                    }
                    setState(() {
                      _draggedNode = null;
                    });
                  }
                },
                onPointerCancel: (_) {
                  setState(() {
                    _draggedNode = null;
                  });
                },
                child: InteractiveViewer(
                  transformationController: _transformController,
                  boundaryMargin: const EdgeInsets.all(800),
                  minScale: 0.25,
                  maxScale: 3.5,
                  panEnabled: _draggedNode == null,
                  scaleEnabled: false,
                  child: MouseRegion(
                    cursor: _hoveredNode != null
                        ? SystemMouseCursors.click
                        : (_draggedNode != null
                              ? SystemMouseCursors.grabbing
                              : SystemMouseCursors.grab),
                    onHover: (event) {
                      final hitNode = _findNodeAt(event.localPosition);
                      if (hitNode != _hoveredNode) {
                        setState(() {
                          _hoveredNode = hitNode;
                        });
                      }
                    },
                    child: CustomPaint(
                      size: _canvasSize,
                      painter: _GraphPainter(
                        graphData: _graphData,
                        activeFile: activeFile,
                        hoveredNode: _hoveredNode,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Thanh chỉ số & công cụ hỗ trợ góc trên bên phải
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1926),
                  borderRadius: BorderRadius.circular(12),
                  border: AppTheme.highlightBorder,
                  boxShadow: AppTheme.cardSoftShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.hub_rounded,
                      size: 15,
                      color: AppTheme.primaryPurple,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_graphData.nodes.length} Nodes  •  ${_graphData.edges.length} Edges',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 1,
                      height: 16,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    const SizedBox(width: 6),
                    Tooltip(
                      message: 'Kích hoạt lại lực đẩy đồ thị',
                      child: IconButton(
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 16,
                          color: AppTheme.primaryPurple,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _buildGraphData,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 16,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    const SizedBox(width: 8),
                    // Điều chỉnh khoảng cách node
                    Tooltip(
                      message: 'Thu hẹp khoảng cách liên kết (-40px)',
                      child: IconButton(
                        icon: Icon(
                          Icons.compress_rounded,
                          size: 15,
                          color: _linkDistance > 160
                              ? Colors.white.withOpacity(0.7)
                              : Colors.white.withOpacity(0.25),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _linkDistance > 160
                            ? () {
                                setState(() {
                                  _linkDistance = (_linkDistance - 40).clamp(
                                    160.0,
                                    480.0,
                                  );
                                });
                                _animationController.repeat();
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_linkDistance.toInt()}px',
                      style: TextStyle(
                        color: AppTheme.primaryPurple.withOpacity(0.95),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: 'Kéo dài khoảng cách liên kết (+40px)',
                      child: IconButton(
                        icon: Icon(
                          Icons.expand_rounded,
                          size: 15,
                          color: _linkDistance < 480
                              ? Colors.white.withOpacity(0.7)
                              : Colors.white.withOpacity(0.25),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _linkDistance < 480
                            ? () {
                                setState(() {
                                  _linkDistance = (_linkDistance + 40).clamp(
                                    160.0,
                                    480.0,
                                  );
                                });
                                _animationController.repeat();
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Tooltip(
                      message: 'Thu nhỏ (Zoom Out)',
                      child: IconButton(
                        icon: Icon(
                          Icons.remove_rounded,
                          size: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          _zoomAt(
                            Offset(
                              _lastViewportSize.width / 2,
                              _lastViewportSize.height / 2,
                            ),
                            0.85,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Tooltip(
                      message: 'Phóng to (Zoom In)',
                      child: IconButton(
                        icon: Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          _zoomAt(
                            Offset(
                              _lastViewportSize.width / 2,
                              _lastViewportSize.height / 2,
                            ),
                            1.2,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Tooltip(
                      message: 'Đặt lại tỉ lệ phóng to (Reset Zoom)',
                      child: IconButton(
                        icon: Icon(
                          Icons.fit_screen_rounded,
                          size: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _resetZoom(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Chú thích hướng dẫn tương tác góc dưới bên trái
            Positioned(
              bottom: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1926),
                  borderRadius: BorderRadius.circular(12),
                  border: AppTheme.highlightBorder,
                  boxShadow: AppTheme.cardSoftShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Cuộn chuột để Zoom  •  Kéo nền để Pan  •  Click Node để mở Note',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// CustomPainter vẽ toàn bộ các cạnh nối (Edges) và các nút (Nodes) theo chuẩn M3
class _GraphPainter extends CustomPainter {
  final GraphData graphData;
  final NoteFile? activeFile;
  final GraphNode? hoveredNode;
  final ColorScheme colorScheme;

  _GraphPainter({
    required this.graphData,
    required this.activeFile,
    required this.hoveredNode,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (graphData.nodes.isEmpty) return;

    final nodeMap = {for (final n in graphData.nodes) n.id: n};
    final activeId = activeFile?.fileName.replaceAll(
      RegExp(r'\.md$', caseSensitive: false),
      '',
    );

    // 1. Vẽ các đường viền nền lưới tinh tế (Background Grid Dot)
    final gridPaint = Paint()
      ..color = colorScheme.outlineVariant.withAlpha(90)
      ..strokeWidth = 1.0;

    const gridSize = 40.0;
    for (var x = 0.0; x < size.width; x += gridSize) {
      for (var y = 0.0; y < size.height; y += gridSize) {
        canvas.drawCircle(Offset(x, y), 0.9, gridPaint);
      }
    }

    // 2. Vẽ các cạnh nối (Edges)
    final edgePaint = Paint()
      ..color = colorScheme.outlineVariant
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final activeEdgePaint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    for (final edge in graphData.edges) {
      final nodeA = nodeMap[edge.sourceId];
      final nodeB = nodeMap[edge.targetId];

      if (nodeA != null && nodeB != null) {
        final isConnectedToActive =
            (activeId != null &&
                (edge.sourceId == activeId || edge.targetId == activeId)) ||
            (hoveredNode != null &&
                (edge.sourceId == hoveredNode!.id ||
                    edge.targetId == hoveredNode!.id));

        canvas.drawLine(
          nodeA.position,
          nodeB.position,
          isConnectedToActive ? activeEdgePaint : edgePaint,
        );
      }
    }

    // 3. Vẽ các Node M3
    for (final node in graphData.nodes) {
      final isActive = node.id == activeId;
      final isHovered = node == hoveredNode;
      final radius = node.radius;

      // Hào quang phát sáng nếu node được chọn hoặc hover
      if (isActive || isHovered) {
        final glowPaint = Paint()
          ..color = colorScheme.primary.withAlpha(isActive ? 110 : 70)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

        canvas.drawCircle(node.position, radius + 8, glowPaint);
      }

      // Thân node (Vòng tròn màu tím M3)
      final nodePaint = Paint()
        ..shader = RadialGradient(
          colors: [colorScheme.primaryContainer, colorScheme.primary],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: node.position, radius: radius));

      canvas.drawCircle(node.position, radius, nodePaint);

      // Viền sáng bóng
      final borderPaint = Paint()
        ..color = isActive
            ? colorScheme.onPrimary
            : (isHovered ? colorScheme.secondary : colorScheme.primaryContainer)
        ..strokeWidth = isActive ? 2.5 : 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(node.position, radius, borderPaint);

      // 4. Nhãn văn bản hiển thị tên file dưới Node
      final textSpan = TextSpan(
        text: node.label,
        style: TextStyle(
          color: isActive
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurface,
          fontSize: isActive ? 12.0 : 11.0,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final labelOffset = Offset(
        node.position.dx - (textPainter.width / 2),
        node.position.dy + radius + 6,
      );

      // Nền badge bao quanh label
      final bgRect = Rect.fromLTWH(
        labelOffset.dx - 5,
        labelOffset.dy - 2,
        textPainter.width + 10,
        textPainter.height + 4,
      );

      final bgPaint = Paint()
        ..color = colorScheme.surfaceContainerHighest.withAlpha(230)
        ..style = PaintingStyle.fill;

      final bgBorderPaint = Paint()
        ..color = isActive ? colorScheme.primary : colorScheme.outlineVariant
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
        bgPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
        bgBorderPaint,
      );

      textPainter.paint(canvas, labelOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return true;
  }
}
