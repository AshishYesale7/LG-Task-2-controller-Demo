import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & About'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── About ─────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.public,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('About',
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'LG Flutter Starter Kit is a comprehensive template for building '
                    'Google Summer of Code (GSoC) projects that interact with the '
                    'Liquid Galaxy multi-display system.',
                  ),
                  const SizedBox(height: 8),
                  const Text('Version: 1.0.0'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ─── SSH Commands ──────────────────────────────────────────
          _buildHelpSection(
            context,
            icon: Icons.terminal,
            title: 'SSH Commands',
            items: [
              'flyTo: Sends flyto command to Google Earth',
              'search: Executes search query on master',
              'reboot: Restarts all LG machines',
              'cleanKMLs: Removes all loaded KML overlays',
              'sendLogo: Displays logo on slave screen',
              'sendPyramid: Sends 3D pyramid to center screen',
              'flyToHomeCity: Camera flight to home city',
              'cleanLogos: Removes logo overlays from slaves',
            ],
          ),
          const SizedBox(height: 16),

          // ─── KML Guide ─────────────────────────────────────────────
          _buildHelpSection(
            context,
            icon: Icons.code,
            title: 'KML Basics',
            items: [
              'Placemarks: Pin locations on Google Earth',
              'Overlays: Display images on screens',
              'LineStrings: Draw paths and trajectories',
              'Polygons: Define geographical areas',
              'NetworkLinks: Dynamic KML from server',
            ],
          ),
          const SizedBox(height: 16),

          // ─── Architecture ──────────────────────────────────────────
          _buildHelpSection(
            context,
            icon: Icons.architecture,
            title: 'Architecture',
            items: [
              'screens/: UI pages (splash, main, connection, settings)',
              'services/: Business logic (SSH, LG, KML)',
              'providers/: State management (settings, theme)',
              'models/: Data classes (connection status)',
              'config.dart: Centralized configuration',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(child: Text(item)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
