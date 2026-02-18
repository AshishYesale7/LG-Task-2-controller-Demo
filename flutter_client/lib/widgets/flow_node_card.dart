import 'package:flutter/material.dart';
import 'package:flutter_client/models/flow_node.dart';

/// A single node card in the flow — styled like an n8n node.
class FlowNodeCard extends StatelessWidget {
  final FlowNode node;
  final bool isSelected;
  final VoidCallback? onTap;

  /// Card dimensions — must match [FlowEdgePainter.nodeSize].
  static const double cardWidth = 200;
  static const double cardHeight = 80;

  const FlowNodeCard({
    super.key,
    required this.node,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: _bgColor(cs),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cs.primary : _borderColor(cs),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? cs.primary : Colors.black)
                  .withValues(alpha: isSelected ? 0.18 : 0.08),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left icon strip.
            Container(
              width: 48,
              decoration: BoxDecoration(
                color: _accentColor(cs).withValues(alpha: 0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  bottomLeft: Radius.circular(11),
                ),
              ),
              child: Center(
                child: Icon(
                  node.icon,
                  color: _accentColor(cs),
                  size: 24,
                ),
              ),
            ),
            // Content.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (node.tag != null)
                      Text(
                        node.tag!,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: _accentColor(cs),
                          letterSpacing: 0.8,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      node.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (node.status != FlowNodeStatus.idle) ...[
                      const SizedBox(height: 4),
                      _StatusChip(status: node.status),
                    ],
                  ],
                ),
              ),
            ),
            // Right connector dot.
            if (node.outputs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.outline.withValues(alpha: 0.4),
                    border:
                        Border.all(color: cs.outline.withValues(alpha: 0.6)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _bgColor(ColorScheme cs) {
    return switch (node.type) {
      FlowNodeType.checkpoint => cs.tertiaryContainer.withValues(alpha: 0.4),
      FlowNodeType.helper => cs.surfaceContainerHighest,
      _ => cs.surface,
    };
  }

  Color _borderColor(ColorScheme cs) {
    return switch (node.status) {
      FlowNodeStatus.active => cs.primary,
      FlowNodeStatus.completed => Colors.green.shade400,
      FlowNodeStatus.blocked => cs.error,
      _ => cs.outlineVariant,
    };
  }

  Color _accentColor(ColorScheme cs) {
    return switch (node.type) {
      FlowNodeType.stage => cs.primary,
      FlowNodeType.helper => cs.secondary,
      FlowNodeType.checkpoint => cs.tertiary,
      FlowNodeType.trigger => Colors.green,
    };
  }
}

/// Tiny status chip shown inside the node card.
class _StatusChip extends StatelessWidget {
  final FlowNodeStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      FlowNodeStatus.active => ('RUNNING', Colors.blue),
      FlowNodeStatus.completed => ('DONE', Colors.green),
      FlowNodeStatus.blocked => ('BLOCKED', Colors.red),
      FlowNodeStatus.idle => ('IDLE', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
