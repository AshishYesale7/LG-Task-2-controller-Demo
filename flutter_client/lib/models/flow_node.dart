import 'package:flutter/material.dart';

/// Represents a node type in the workflow.
enum FlowNodeType {
  /// A pipeline stage (numbered step).
  stage,

  /// A cross-cutting / helper skill.
  helper,

  /// A checkpoint that requires student interaction.
  checkpoint,

  /// A trigger / entry point.
  trigger,
}

/// Status of a workflow node.
enum FlowNodeStatus {
  /// Not yet started.
  idle,

  /// Currently active.
  active,

  /// Completed successfully.
  completed,

  /// Blocked / requires attention.
  blocked,
}

/// A single node in the workflow flow chart.
class FlowNode {
  /// Unique identifier.
  final String id;

  /// Display label (short).
  final String label;

  /// Longer description shown in detail sheet.
  final String description;

  /// The skill file path associated with this node.
  final String? skillPath;

  /// Visual type.
  final FlowNodeType type;

  /// Current execution status.
  final FlowNodeStatus status;

  /// Icon shown on the card.
  final IconData icon;

  /// Position on the canvas (logical coordinates).
  final Offset position;

  /// IDs of nodes that follow this one.
  final List<String> outputs;

  /// Tag / subtitle — e.g. "Stage 2", "Cross-cutting".
  final String? tag;

  /// Student checkpoint question (if type == checkpoint or has one).
  final String? checkpointQuestion;

  const FlowNode({
    required this.id,
    required this.label,
    required this.description,
    this.skillPath,
    this.type = FlowNodeType.stage,
    this.status = FlowNodeStatus.idle,
    this.icon = Icons.square_rounded,
    this.position = Offset.zero,
    this.outputs = const [],
    this.tag,
    this.checkpointQuestion,
  });

  FlowNode copyWith({
    String? label,
    String? description,
    FlowNodeType? type,
    FlowNodeStatus? status,
    IconData? icon,
    Offset? position,
    List<String>? outputs,
    String? tag,
    String? checkpointQuestion,
  }) {
    return FlowNode(
      id: id,
      label: label ?? this.label,
      description: description ?? this.description,
      skillPath: skillPath,
      type: type ?? this.type,
      status: status ?? this.status,
      icon: icon ?? this.icon,
      position: position ?? this.position,
      outputs: outputs ?? this.outputs,
      tag: tag ?? this.tag,
      checkpointQuestion: checkpointQuestion ?? this.checkpointQuestion,
    );
  }
}

/// A directed connection between two flow nodes.
class FlowEdge {
  final String fromId;
  final String toId;

  /// Optional label on the edge (e.g. "if revisions needed").
  final String? label;

  /// Whether this is a conditional / feedback edge.
  final bool isConditional;

  const FlowEdge({
    required this.fromId,
    required this.toId,
    this.label,
    this.isConditional = false,
  });
}
