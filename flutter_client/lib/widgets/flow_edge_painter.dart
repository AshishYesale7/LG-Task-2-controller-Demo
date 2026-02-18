import 'package:flutter/material.dart';
import 'package:flutter_client/models/flow_node.dart';

/// Paints bezier-curve connections between flow nodes — n8n style.
class FlowEdgePainter extends CustomPainter {
  final List<FlowEdge> edges;
  final Map<String, FlowNode> nodeMap;

  /// The size of a single node card (used to calc connector positions).
  final Size nodeSize;

  FlowEdgePainter({
    required this.edges,
    required this.nodeMap,
    this.nodeSize = const Size(200, 80),
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final edge in edges) {
      final from = nodeMap[edge.fromId];
      final to = nodeMap[edge.toId];
      if (from == null || to == null) continue;

      // Output port: right-center of the "from" node.
      final startX = from.position.dx + nodeSize.width;
      final startY = from.position.dy + nodeSize.height / 2;

      // Input port: left-center of the "to" node.
      final endX = to.position.dx;
      final endY = to.position.dy + nodeSize.height / 2;

      final start = Offset(startX, startY);
      final end = Offset(endX, endY);

      // Bezier control points — n8n style horizontal curves.
      final dx = (end.dx - start.dx).abs() * 0.5;
      final cp1 = Offset(start.dx + dx, start.dy);
      final cp2 = Offset(end.dx - dx, end.dy);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = edge.isConditional
            ? Colors.orange.withValues(alpha: 0.7)
            : Colors.grey.withValues(alpha: 0.5);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

      canvas.drawPath(path, paint);

      // Draw arrow head at end.
      _drawArrowHead(canvas, end, cp2, paint.color);

      // Draw edge label if present.
      if (edge.label != null) {
        final midX = (start.dx + end.dx) / 2;
        final midY = (start.dy + end.dy) / 2;
        final textPainter = TextPainter(
          text: TextSpan(
            text: edge.label,
            style: TextStyle(
              color: paint.color,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(midX - textPainter.width / 2, midY - textPainter.height - 4),
        );
      }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset tip, Offset from, Color color) {
    final direction = (tip - from);
    final normalized = direction / direction.distance;
    final perpendicular = Offset(-normalized.dy, normalized.dx);

    const arrowLength = 10.0;
    const arrowWidth = 5.0;

    final p1 = tip - normalized * arrowLength + perpendicular * arrowWidth;
    final p2 = tip - normalized * arrowLength - perpendicular * arrowWidth;

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final arrowPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant FlowEdgePainter oldDelegate) =>
      edges.length != oldDelegate.edges.length ||
      nodeMap.length != oldDelegate.nodeMap.length;
}
