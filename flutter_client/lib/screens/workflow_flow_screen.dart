import 'package:flutter/material.dart';
import 'package:flutter_client/models/flow_node.dart';
import 'package:flutter_client/widgets/flow_node_card.dart';
import 'package:flutter_client/widgets/flow_edge_painter.dart';

// ---------------------------------------------------------------------------
// Antigravity pipeline data — matches .agent/workflows/full-pipeline.md
// ---------------------------------------------------------------------------

/// Horizontal / vertical spacing constants for the layout grid.
const double _colW = 260; // horizontal distance between columns
const double _rowH = 120; // vertical distance between rows
const double _topPad = 40; // top margin
const double _leftPad = 40; // left margin

Offset _pos(int col, int row) =>
    Offset(_leftPad + col * _colW, _topPad + row * _rowH);

/// All nodes in the Antigravity educational pipeline.
List<FlowNode> _buildPipelineNodes() => [
      // ── Row 0: Main pipeline (left → right) ──────────────────────────
      FlowNode(
        id: 'env_doctor',
        label: 'Environment Doctor',
        description:
            'Detects host OS, checks all required tools (Flutter, Dart, Git, JDK 17, Android SDK, SSH, Node.js). Produces a health report. Blocks pipeline if tools are missing.',
        skillPath: '.agent/skills/lg-env-doctor/SKILL.md',
        type: FlowNodeType.trigger,
        icon: Icons.health_and_safety,
        position: _pos(0, 0),
        outputs: ['shield_pre'],
        tag: 'PRE-STAGE',
      ),
      FlowNode(
        id: 'shield_pre',
        label: 'Security Pre-Flight',
        description:
            'Scans for hardcoded secrets, validates .gitignore, checks flutter_secure_storage usage, and verifies layer boundary compliance.',
        skillPath: '.agent/skills/lg-shield/SKILL.md',
        type: FlowNodeType.stage,
        icon: Icons.shield,
        position: _pos(1, 0),
        outputs: ['init'],
        tag: 'STAGE 0',
      ),
      FlowNode(
        id: 'init',
        label: 'Init Project',
        description:
            'Enforces LG-<TaskName> naming, creates new app in a separate sibling directory, scaffolds layered architecture, configures dependencies, generates logo via Nano Banana, runs flutter analyze.',
        skillPath: '.agent/skills/lg-init/SKILL.md',
        type: FlowNodeType.stage,
        icon: Icons.rocket_launch,
        position: _pos(2, 0),
        outputs: ['cp_init'],
        tag: 'STAGE 1',
      ),
      FlowNode(
        id: 'cp_init',
        label: 'Checkpoint: Init',
        description:
            '"The project is scaffolded. Explain: What is the relationship between the Flutter app on your phone and Google Earth on the LG rig?"',
        type: FlowNodeType.checkpoint,
        icon: Icons.pause_circle_filled,
        position: _pos(3, 0),
        outputs: ['brainstorm'],
        tag: '⛔️ STOP',
        checkpointQuestion:
            'What is the relationship between the Flutter app and the LG rig?',
      ),
      FlowNode(
        id: 'brainstorm',
        label: 'Brainstorm',
        description:
            'Explores the idea collaboratively. References real LG projects. Proposes 2-3 approaches with trade-offs. Selects optimal design. Documents in docs/plans/.',
        skillPath: '.agent/skills/lg-brainstormer/SKILL.md',
        type: FlowNodeType.stage,
        icon: Icons.lightbulb,
        position: _pos(4, 0),
        outputs: ['cp_brainstorm'],
        tag: 'STAGE 2',
      ),

      // ── Row 1: continues ─────────────────────────────────────────────
      FlowNode(
        id: 'cp_brainstorm',
        label: 'Checkpoint: Brainstorm',
        description:
            '"Describe the data flow: where does data come from, how becomes KML, how reaches Google Earth?"',
        type: FlowNodeType.checkpoint,
        icon: Icons.pause_circle_filled,
        position: _pos(0, 1),
        outputs: ['viz_arch'],
        tag: '⛔️ STOP',
        checkpointQuestion:
            'Describe the data flow from API to Google Earth on the rig.',
      ),
      FlowNode(
        id: 'viz_arch',
        label: 'Viz Architect',
        description:
            'Designs the multi-screen experience storyboard. Maps data to KML elements. Defines phone-to-rig interaction. Sets performance budget.',
        skillPath: '.agent/skills/lg-viz-architect/SKILL.md',
        type: FlowNodeType.stage,
        icon: Icons.panorama,
        position: _pos(1, 1),
        outputs: ['plan'],
        tag: 'STAGE 3',
      ),
      FlowNode(
        id: 'plan',
        label: 'Plan Writer',
        description:
            'Breaks design into bite-sized tasks. Defines file paths and code patterns per layer. Includes educational verification phase.',
        skillPath: '.agent/skills/lg-plan-writer/SKILL.md',
        type: FlowNodeType.stage,
        icon: Icons.list_alt,
        position: _pos(2, 1),
        outputs: ['cp_plan'],
        tag: 'STAGE 4',
      ),
      FlowNode(
        id: 'cp_plan',
        label: 'Checkpoint: Plan',
        description:
            '"Before we start coding — why does SSH logic belong in a service and not a widget? What principle is that?"',
        type: FlowNodeType.checkpoint,
        icon: Icons.pause_circle_filled,
        position: _pos(3, 1),
        outputs: ['data_pipeline'],
        tag: '⛔️ STOP',
        checkpointQuestion:
            'Why does SSH logic belong in a service, not a widget?',
      ),
      FlowNode(
        id: 'data_pipeline',
        label: 'Data Pipeline',
        description:
            'Defines provider contracts for external APIs. Creates domain models (immutable). Wires API → Domain → KML → Transport flow.',
        skillPath: '.agent/skills/lg-data-pipeline/SKILL.md',
        type: FlowNodeType.stage,
        icon: Icons.transform,
        position: _pos(4, 1),
        outputs: ['ui_kml'],
        tag: 'STAGE 5',
      ),

      // ── Row 2: continues ─────────────────────────────────────────────
      FlowNode(
        id: 'ui_kml',
        label: 'UI Scaffold + KML Craft',
        description:
            'Generates controller screens (no network/KML/SSH imports in UI). Composes artistic KML visualizations. Wires screens to services via Provider.',
        skillPath: '.agent/skills/lg-ui-scaffolder/SKILL.md',
        type: FlowNodeType.stage,
        icon: Icons.auto_awesome,
        position: _pos(0, 2),
        outputs: ['execute'],
        tag: 'STAGE 6',
      ),
      FlowNode(
        id: 'execute',
        label: 'Execute (Batches)',
        description:
            'Executes tasks in batches of 2-3 MAX. Stops after each batch for student verification. Runs flutter analyze + test. Commits and pushes after each batch.',
        skillPath: '.agent/skills/lg-exec/SKILL.md',
        type: FlowNodeType.stage,
        icon: Icons.play_circle,
        position: _pos(1, 2),
        outputs: ['cp_execute'],
        tag: 'STAGE 7',
      ),
      FlowNode(
        id: 'cp_execute',
        label: 'Checkpoint: Execute',
        description:
            'Verification question about what was just built. One question per batch. Must wait for student answer.',
        type: FlowNodeType.checkpoint,
        icon: Icons.pause_circle_filled,
        position: _pos(2, 2),
        outputs: ['review'],
        tag: '⛔️ STOP',
        checkpointQuestion:
            'Explain what was just built and how it connects to the rest of the app.',
      ),
      FlowNode(
        id: 'review',
        label: 'Code Review',
        description:
            'Holistic quality check (SOLID, DRY, naming). Tooling audit (analyze, format, tests). LG-specific audit (KML, SSH lifecycle, boundaries). Writes review report.',
        skillPath: '.agent/skills/lg-code-reviewer/SKILL.md',
        type: FlowNodeType.stage,
        icon: Icons.rate_review,
        position: _pos(3, 2),
        outputs: ['shield_post'],
        tag: 'STAGE 8',
      ),
      FlowNode(
        id: 'shield_post',
        label: 'Security Post-Flight',
        description:
            'Re-runs full security and boundary scan on final code. Verifies no regressions. Generates shield report. Blocks graduation if critical issues found.',
        skillPath: '.agent/skills/lg-shield/SKILL.md',
        type: FlowNodeType.stage,
        icon: Icons.shield,
        position: _pos(4, 2),
        outputs: ['quiz'],
        tag: 'STAGE 9',
      ),

      // ── Row 3: graduation ────────────────────────────────────────────
      FlowNode(
        id: 'quiz',
        label: 'Quiz & Graduation',
        description:
            '5-question assessment covering Command Flow, KML, Engineering, Layer Boundaries, Security. Runs app on emulator for live demo. Captures evidence via demo-recorder.',
        skillPath: '.agent/skills/lg-quiz-master/SKILL.md',
        type: FlowNodeType.stage,
        icon: Icons.school,
        position: _pos(2, 3),
        outputs: [],
        tag: 'STAGE 10',
      ),

      // ── Row 4: cross-cutting helpers ─────────────────────────────────
      FlowNode(
        id: 'critical_advisor',
        label: 'Critical Advisor',
        description:
            'Active at ALL stages. Triggers on rushing, over-delegating, boundary violations, security issues, silent passenger. Enforces rigor.',
        skillPath: '.agent/skills/lg-critical-advisor/SKILL.md',
        type: FlowNodeType.helper,
        icon: Icons.warning_amber,
        position: _pos(0, 4),
        outputs: [],
        tag: 'CROSS-CUTTING',
      ),
      FlowNode(
        id: 'dep_resolver',
        label: 'Dependency Resolver',
        description:
            'Triggers when flutter pub get, Gradle, or CocoaPods fails. Classifies error and applies targeted fix.',
        skillPath: '.agent/skills/lg-dependency-resolver/SKILL.md',
        type: FlowNodeType.helper,
        icon: Icons.build_circle,
        position: _pos(1, 4),
        outputs: [],
        tag: 'ON-DEMAND',
      ),
      FlowNode(
        id: 'resume_pipeline',
        label: 'Resume Pipeline',
        description:
            'Reads checkpoint file on session reconnect. Resumes from exact interrupted stage automatically.',
        skillPath: '.agent/skills/lg-resume-pipeline/SKILL.md',
        type: FlowNodeType.helper,
        icon: Icons.restart_alt,
        position: _pos(2, 4),
        outputs: [],
        tag: 'ON-DEMAND',
      ),
      FlowNode(
        id: 'learning_resources',
        label: 'Learning Resources',
        description:
            'Links to LG official sources, YouTube tutorials, Flutter docs. Maps quiz wrong answers and knowledge gaps to targeted resources.',
        skillPath: '.agent/skills/lg-learning-resources/SKILL.md',
        type: FlowNodeType.helper,
        icon: Icons.menu_book,
        position: _pos(3, 4),
        outputs: [],
        tag: 'ON-DEMAND',
      ),
      FlowNode(
        id: 'demo_recorder',
        label: 'Demo Recorder',
        description:
            'Captures full demo evidence — screenshots, screen recordings, GIF for README. Produces contest-ready Task 2 evidence package.',
        skillPath: '.agent/skills/lg-demo-recorder/SKILL.md',
        type: FlowNodeType.helper,
        icon: Icons.videocam,
        position: _pos(4, 4),
        outputs: [],
        tag: 'ON-DEMAND',
      ),
    ];

/// All edges in the pipeline.
List<FlowEdge> _buildPipelineEdges() => const [
      // Main forward flow
      FlowEdge(fromId: 'env_doctor', toId: 'shield_pre'),
      FlowEdge(fromId: 'shield_pre', toId: 'init'),
      FlowEdge(fromId: 'init', toId: 'cp_init'),
      FlowEdge(fromId: 'cp_init', toId: 'brainstorm'),
      FlowEdge(fromId: 'brainstorm', toId: 'cp_brainstorm'),
      FlowEdge(fromId: 'cp_brainstorm', toId: 'viz_arch'),
      FlowEdge(fromId: 'viz_arch', toId: 'plan'),
      FlowEdge(fromId: 'plan', toId: 'cp_plan'),
      FlowEdge(fromId: 'cp_plan', toId: 'data_pipeline'),
      FlowEdge(fromId: 'data_pipeline', toId: 'ui_kml'),
      FlowEdge(fromId: 'ui_kml', toId: 'execute'),
      FlowEdge(fromId: 'execute', toId: 'cp_execute'),
      FlowEdge(fromId: 'cp_execute', toId: 'review'),
      FlowEdge(fromId: 'review', toId: 'shield_post'),
      FlowEdge(fromId: 'shield_post', toId: 'quiz'),
      // Feedback loop: review → execute (if revisions needed)
      FlowEdge(
        fromId: 'review',
        toId: 'execute',
        label: 'revisions needed',
        isConditional: true,
      ),
    ];

// ---------------------------------------------------------------------------
// Workflow Flow Screen
// ---------------------------------------------------------------------------

/// n8n-style interactive workflow visualization of the Antigravity pipeline.
class WorkflowFlowScreen extends StatefulWidget {
  const WorkflowFlowScreen({super.key});

  @override
  State<WorkflowFlowScreen> createState() => _WorkflowFlowScreenState();
}

class _WorkflowFlowScreenState extends State<WorkflowFlowScreen> {
  late List<FlowNode> _nodes;
  late List<FlowEdge> _edges;
  late Map<String, FlowNode> _nodeMap;

  String? _selectedNodeId;

  final TransformationController _transformCtrl = TransformationController();

  @override
  void initState() {
    super.initState();
    _nodes = _buildPipelineNodes();
    _edges = _buildPipelineEdges();
    _nodeMap = {for (final n in _nodes) n.id: n};
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Antigravity Workflow'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom In',
            onPressed: _zoomIn,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom Out',
            onPressed: _zoomOut,
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen),
            tooltip: 'Fit to screen',
            onPressed: _resetView,
          ),
        ],
      ),
      body: Column(
        children: [
          // Legend bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: cs.surfaceContainerLow,
            child: Row(
              children: [
                _legendDot(cs.primary, 'Stage'),
                const SizedBox(width: 16),
                _legendDot(cs.tertiary, 'Checkpoint'),
                const SizedBox(width: 16),
                _legendDot(cs.secondary, 'Helper'),
                const SizedBox(width: 16),
                _legendDot(Colors.green, 'Trigger'),
                const Spacer(),
                Text(
                  'Pinch / scroll to zoom  •  Drag to pan',
                  style: TextStyle(fontSize: 11, color: cs.outline),
                ),
              ],
            ),
          ),
          // Canvas
          Expanded(
            child: InteractiveViewer(
              transformationController: _transformCtrl,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(400),
              minScale: 0.15,
              maxScale: 2.5,
              child: SizedBox(
                // Make the canvas large enough for all nodes.
                width: _leftPad * 2 + 5 * _colW + FlowNodeCard.cardWidth,
                height: _topPad * 2 + 5 * _rowH + FlowNodeCard.cardHeight,
                child: Stack(
                  children: [
                    // Edges (painted underneath nodes).
                    Positioned.fill(
                      child: CustomPaint(
                        painter: FlowEdgePainter(
                          edges: _edges,
                          nodeMap: _nodeMap,
                          nodeSize: const Size(
                            FlowNodeCard.cardWidth,
                            FlowNodeCard.cardHeight,
                          ),
                        ),
                      ),
                    ),
                    // Nodes.
                    for (final node in _nodes)
                      Positioned(
                        left: node.position.dx,
                        top: node.position.dy,
                        child: FlowNodeCard(
                          node: node,
                          isSelected: _selectedNodeId == node.id,
                          onTap: () => _onNodeTap(node),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  void _onNodeTap(FlowNode node) {
    setState(() {
      _selectedNodeId = node.id == _selectedNodeId ? null : node.id;
    });
    if (_selectedNodeId != null) {
      _showNodeDetail(node);
    }
  }

  void _showNodeDetail(FlowNode node) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.25,
          maxChildSize: 0.75,
          expand: false,
          builder: (_, scrollCtrl) {
            return ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(node.icon, color: cs.primary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (node.tag != null)
                            Text(
                              node.tag!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          Text(
                            node.label,
                            style: Theme.of(ctx).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  node.description,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
                if (node.skillPath != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.folder_outlined,
                            size: 16, color: cs.outline),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            node.skillPath!,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (node.checkpointQuestion != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.tertiaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.tertiary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.quiz,
                                size: 16, color: cs.tertiary),
                            const SizedBox(width: 6),
                            Text(
                              'Student Checkpoint',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: cs.tertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          node.checkpointQuestion!,
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: cs.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (node.outputs.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Next →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.outline,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: node.outputs.map((id) {
                      final target = _nodeMap[id];
                      return ActionChip(
                        avatar:
                            Icon(target?.icon ?? Icons.arrow_forward, size: 16),
                        label:
                            Text(target?.label ?? id, style: const TextStyle(fontSize: 12)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          if (target != null) {
                            setState(() => _selectedNodeId = target.id);
                            _showNodeDetail(target);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  void _zoomIn() {
    final current = _transformCtrl.value.clone();
    current.scale(1.3, 1.3, 1.3);
    _transformCtrl.value = current;
  }

  void _zoomOut() {
    final current = _transformCtrl.value.clone();
    current.scale(0.7, 0.7, 0.7);
    _transformCtrl.value = current;
  }

  void _resetView() {
    _transformCtrl.value = Matrix4.identity();
  }
}
