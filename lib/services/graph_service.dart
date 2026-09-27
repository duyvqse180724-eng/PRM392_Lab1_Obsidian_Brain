import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../models/graph_data.dart';
import '../models/note_file.dart';

/// Dịch vụ phân tích mạng lưới liên kết Markdown Wikilinks và xây dựng Graph Model
class GraphService {
  const GraphService();

  /// Phân tích danh sách file trong Vault để tạo GraphData
  GraphData buildGraph(
    List<NoteFile> files, {
    Size canvasSize = const Size(2200, 1600),
  }) {
    if (files.isEmpty) {
      return GraphData.empty;
    }

    try {
      final Map<String, GraphNode> nodeMap = {};
      final Set<GraphEdge> edgeSet = {};

      // 1. Chuẩn hóa ID và tạo các Node
      final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
      final count = files.length;
      final initialRadius = math.max(
        420.0,
        math.min(canvasSize.width, canvasSize.height) * 0.38,
      );

      for (var i = 0; i < count; i++) {
        final file = files[i];
        final id = _normalizeId(file.fileName);

        // Phân bố ban đầu dạng vòng tròn xung quanh tâm
        final angle = (2 * math.pi / count) * i;
        final initialPos = Offset(
          center.dx + initialRadius * math.cos(angle),
          center.dy + initialRadius * math.sin(angle),
        );

        nodeMap[id] = GraphNode(
          id: id,
          label: id,
          file: file,
          position: initialPos,
        );
      }

      // 2. Quét nội dung từng file tìm cú pháp [[Tên_File]] hoặc [[Tên_File|Alias]] hoặc [[Tên_File#Heading]]
      final wikiLinkRegex = RegExp(r'\[\[(.*?)\]\]');
      // Tạo lookup map không phân biệt hoa thường để liên kết chính xác
      final Map<String, String> caseInsensitiveLookup = {
        for (final id in nodeMap.keys) id.toLowerCase(): id,
      };

      for (final file in files) {
        final sourceId = _normalizeId(file.fileName);
        if (!nodeMap.containsKey(sourceId)) continue;

        try {
          final matches = wikiLinkRegex.allMatches(file.content);
          for (final match in matches) {
            final rawTarget = match.group(1);
            if (rawTarget == null) continue;

            final targetNormalized = _normalizeId(rawTarget);
            final targetId =
                caseInsensitiveLookup[targetNormalized.toLowerCase()];

            // Kiểm tra node đích có tồn tại trong Vault hay không
            if (targetId != null &&
                targetId != sourceId &&
                nodeMap.containsKey(targetId)) {
              final edge = GraphEdge(sourceId: sourceId, targetId: targetId);
              if (edgeSet.add(edge)) {
                nodeMap[sourceId]!.connections++;
                nodeMap[targetId]!.connections++;
              }
            }
          }
        } catch (e) {
          debugPrint('Lỗi khi parse Regex cho file ${file.fileName}: $e');
        }
      }

      return GraphData(nodes: nodeMap.values.toList(), edges: edgeSet.toList());
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi xây dựng Graph Model: $e\n$stackTrace');
      return GraphData.empty;
    }
  }

  String _normalizeId(String fileName) {
    var clean = fileName.trim();
    // Bỏ alias nếu có dạng [[Target|Tên hiển thị]]
    if (clean.contains('|')) {
      clean = clean.split('|').first.trim();
    }
    // Bỏ heading nếu có dạng [[Target#Heading]]
    if (clean.contains('#')) {
      clean = clean.split('#').first.trim();
    }
    return clean.replaceAll(RegExp(r'\.md$', caseSensitive: false), '').trim();
  }
}
