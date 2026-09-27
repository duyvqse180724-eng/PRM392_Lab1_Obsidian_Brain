import 'dart:ui';

import 'note_file.dart';

/// Node đại diện cho một file Markdown trên đồ thị tri thức
class GraphNode {
  final String id;
  final String label;
  final NoteFile file;
  int connections;
  Offset position;
  Offset velocity;

  GraphNode({
    required this.id,
    required this.label,
    required this.file,
    this.connections = 0,
    required this.position,
    this.velocity = Offset.zero,
  });

  /// Bán kính hiển thị của node phụ thuộc vào số lượng liên kết
  double get radius => (14.0 + (connections * 2.5)).clamp(14.0, 32.0);
}

/// Cạnh nối liên kết giữa 2 file qua cú pháp [[WikiLink]]
class GraphEdge {
  final String sourceId;
  final String targetId;

  const GraphEdge({required this.sourceId, required this.targetId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GraphEdge &&
        ((other.sourceId == sourceId && other.targetId == targetId) ||
            (other.sourceId == targetId && other.targetId == sourceId));
  }

  @override
  int get hashCode => sourceId.hashCode ^ targetId.hashCode;
}

/// Dữ liệu toàn bộ đồ thị tri thức của Vault
class GraphData {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  const GraphData({required this.nodes, required this.edges});

  static const GraphData empty = GraphData(nodes: [], edges: []);
}
