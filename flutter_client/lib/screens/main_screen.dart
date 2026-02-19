import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lg_task2_demo/services/lg_service.dart';
import 'package:lg_task2_demo/providers/settings_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isLoading = false;
  String? _statusMessage;

  Future<void> _executeAction(Future<void> Function() action) async {
    setState(() => _isLoading = true);
    try {
      await action();
      setState(() => _statusMessage = 'Action completed successfully');
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Listen to LGService errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lgService = context.read<LGService>();
      lgService.onError.listen((error) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(error),
               backgroundColor: Colors.red,
               duration: const Duration(seconds: 4),
             ),
           );
        }
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    final lgService = context.watch<LGService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LG Controller'),
        centerTitle: true,
        actions: [

          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.pushNamed(context, '/help'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      lgService.isConnected ? Icons.check_circle : Icons.error,
                      color: lgService.isConnected ? Colors.green : Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lgService.isConnected
                          ? 'Connected to LG Rig'
                          : 'Not Connected (Demo Mode)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_statusMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: _statusMessage!.startsWith('Error')
                              ? Theme.of(context).colorScheme.error
                              : Colors.green,
                        ),
                      ),
                    ],
                    if (_isLoading) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ─── 5 Core Task 2 Operations ──────────────────────────
            _buildActionButton(
              'Send Logo',
              Icons.image,
              () => _executeAction(() => lgService.sendLogo()),
            ),
            _buildActionButton(
              'Send Pyramid',
              Icons.change_history,
              () => _executeAction(() => lgService.sendPyramid()),
            ),
            _buildActionButton(
              'Fly to Home City',
              Icons.flight,
              () => _executeAction(() => lgService.flyToHomeCity()),
            ),
            _buildActionButton(
              'Remove Logo',
              Icons.layers_clear,
              () => _executeAction(() => lgService.cleanLogos()),
            ),
            _buildActionButton(
              'Show Weather (Lleida)',
              Icons.cloud,
              () {
                final settings = context.read<SettingsProvider>();
                if (settings.weatherApiKey.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please set Weather API Key in Settings')),
                  );
                  return;
                }
                _executeAction(() => lgService.sendWeather('Lleida', settings.weatherApiKey));
              },
            ),
            _buildActionButton(
              'Clean KML + Logos',
              Icons.delete_sweep,
              () => _executeAction(() => lgService.cleanKMLAndLogos()),
            ),
            const Divider(height: 32),

            // ─── Additional Operations ──────────────────────────────
            _buildActionButton(
              'Send KML Placemark',
              Icons.code,
              () => _executeAction(() => lgService.sendKMLPlacemark(
                    name: 'Lleida',
                    latitude: 41.6176,
                    longitude: 0.6200,
                    description: 'Welcome to Lleida!',
                  )),
            ),
            _buildActionButton(
              'Reboot LG',
              Icons.restart_alt,
              () => _executeAction(() => lgService.rebootLG()),
            ),
            _buildActionButton(
              'Disconnect',
              Icons.power_settings_new,
              () {
                lgService.disconnect();
                Navigator.pushReplacementNamed(context, '/connection');
              },
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: color != null
            ? ElevatedButton.styleFrom(foregroundColor: color)
            : null,
      ),
    );
  }
}
