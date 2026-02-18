import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_client/config.dart';

/// Demonstrates connecting to a Node.js backend server.
///
/// This optional screen teaches students how to integrate a Flutter
/// app with a Node.js API server. All network calls are mocked so
/// the screen works without a running server.
class NodeJsScreen extends StatefulWidget {
  const NodeJsScreen({super.key});

  @override
  State<NodeJsScreen> createState() => _NodeJsScreenState();
}

class _NodeJsScreenState extends State<NodeJsScreen> {
  /// Base URL pulled from central config.
  final String _serverUrl = Config.serverUrl;

  /// `null` = unknown, `true` = online, `false` = offline.
  bool? _serverOnline;

  /// Whether a network operation is in flight.
  bool _isLoading = false;

  /// Pretty-printed JSON response from the last API call.
  String? _apiResponse;

  // ─── Mock network helpers ──────────────────────────────────────────

  /// Simulates a health-check against the Node.js server.
  ///
  /// In a real app you would use `http.get(Uri.parse('$_serverUrl/health'))`.
  Future<void> _checkServerStatus() async {
    setState(() {
      _isLoading = true;
      _apiResponse = null;
    });

    // Simulate network latency
    await Future.delayed(const Duration(seconds: 1));

    // Always report offline in demo mode
    setState(() {
      _serverOnline = false;
      _isLoading = false;
      _apiResponse = 'Server at $_serverUrl is offline.\n'
          'Start your Node.js server to connect.';
    });
  }

  /// Simulates calling different API endpoints on the Node.js server.
  ///
  /// In production, replace the mock logic with real `http` calls, e.g.:
  /// ```dart
  /// final response = await http.post(
  ///   Uri.parse('$_serverUrl$endpoint'),
  ///   headers: {'Content-Type': 'application/json'},
  ///   body: body,
  /// );
  /// ```
  Future<void> _callEndpoint(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    setState(() {
      _isLoading = true;
      _apiResponse = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    late Map<String, dynamic> mockResponse;

    switch (endpoint) {
      case '/api/status':
        mockResponse = {
          'status': 'ok',
          'uptime': 12345,
          'version': '1.0.0',
          'screens': Config.totalScreens,
        };
        break;
      case '/api/kml/generate':
        mockResponse = {
          'success': true,
          'kml': '<Placemark>…</Placemark>',
          'message': 'KML generated and sent to LG rig',
          'timestamp': DateTime.now().toIso8601String(),
        };
        break;
      case '/api/data':
        mockResponse = {
          'data': [
            {'id': 1, 'name': 'Lleida', 'lat': 41.6176, 'lng': 0.6200},
            {'id': 2, 'name': 'Barcelona', 'lat': 41.3851, 'lng': 2.1734},
            {'id': 3, 'name': 'Madrid', 'lat': 40.4168, 'lng': -3.7038},
          ],
          'count': 3,
        };
        break;
      default:
        mockResponse = {'error': 'Unknown endpoint: $endpoint'};
    }

    const encoder = JsonEncoder.withIndent('  ');
    setState(() {
      _isLoading = false;
      _apiResponse = '$method $endpoint\n\n${encoder.convert(mockResponse)}';
    });
  }

  // ─── UI ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Node.js Server')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Server status card ──────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Green / red / grey indicator dot
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _serverOnline == null
                            ? Colors.grey
                            : _serverOnline!
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Server Status',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _serverOnline == null
                                ? 'Unknown – tap Check to test'
                                : _serverOnline!
                                    ? 'Online ($_serverUrl)'
                                    : 'Offline ($_serverUrl)',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _isLoading ? null : _checkServerStatus,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Check'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Endpoint cards ──────────────────────────────────────
            _buildEndpointCard(
              title: 'GET /api/status',
              subtitle: 'Returns server health & rig info',
              icon: Icons.monitor_heart_outlined,
              onTap: () => _callEndpoint('/api/status'),
            ),
            _buildEndpointCard(
              title: 'POST /api/kml/generate',
              subtitle: 'Generate and push KML to LG',
              icon: Icons.map_outlined,
              onTap: () => _callEndpoint(
                '/api/kml/generate',
                method: 'POST',
                body: {'type': 'placemark', 'name': 'Demo'},
              ),
            ),
            _buildEndpointCard(
              title: 'GET /api/data',
              subtitle: 'Fetch sample location dataset',
              icon: Icons.dataset_outlined,
              onTap: () => _callEndpoint('/api/data'),
            ),
            const SizedBox(height: 16),

            // ── Response panel ──────────────────────────────────────
            if (_isLoading) const LinearProgressIndicator(),
            if (_apiResponse != null) ...[
              const SizedBox(height: 8),
              Card(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _apiResponse!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // ── Setup guide ─────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Setup Guide',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Install Node.js (v18+)\n'
                      '2. cd into the server/ directory\n'
                      '3. Run: npm install\n'
                      '4. Run: npm start\n'
                      '5. Server will start at ${Config.serverUrl}\n\n'
                      'Tip: The server URL can be changed in config.dart.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a tappable card representing a single API endpoint.
  Widget _buildEndpointCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: _isLoading ? null : onTap,
      ),
    );
  }
}
