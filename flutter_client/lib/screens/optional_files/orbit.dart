import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_client/services/lg_service.dart';

/// Orbit demo screen – lets students fly to a location and start
/// a full 360° camera orbit around it on the Liquid Galaxy rig.
///
/// Uses [LGService] for fly-to commands and [KMLService] to build
/// the orbit tour KML that Google Earth plays back.
class OrbitScreen extends StatefulWidget {
  const OrbitScreen({super.key});

  @override
  State<OrbitScreen> createState() => _OrbitScreenState();
}

class _OrbitScreenState extends State<OrbitScreen> {
  final _formKey = GlobalKey<FormState>();

  final _latController = TextEditingController(text: '41.6176');
  final _lngController = TextEditingController(text: '0.6200');
  final _altController = TextEditingController(text: '1000');
  final _rangeController = TextEditingController(text: '5000');

  bool _isOrbiting = false;
  String? _statusMessage;

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _altController.dispose();
    _rangeController.dispose();
    super.dispose();
  }

  /// Validates inputs, flies to the target, and starts an orbit tour.
  Future<void> _startOrbit() async {
    if (!_formKey.currentState!.validate()) return;

    final lgService = context.read<LGService>();

    final lat = double.parse(_latController.text);
    final lng = double.parse(_lngController.text);
    final alt = double.parse(_altController.text);
    final range = double.parse(_rangeController.text);

    setState(() {
      _isOrbiting = true;
      _statusMessage = 'Flying to location…';
    });

    try {
      // Fly to the target point first
      await lgService.flyTo(
        latitude: lat,
        longitude: lng,
        altitude: alt,
        range: range,
        tilt: 60,
      );

      setState(() => _statusMessage = 'Generating orbit KML…');

      // Build and upload the orbit tour via LGService
      await lgService.sendOrbit(
        latitude: lat,
        longitude: lng,
        altitude: alt,
        range: range,
      );

      setState(() => _statusMessage = 'Orbit started! Duration ≈ 30 s');
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isOrbiting = false);
    }
  }

  /// Stops any active orbit by clearing the KML playlist.
  Future<void> _stopOrbit() async {
    final lgService = context.read<LGService>();
    try {
      await lgService.executeRaw('echo "" > /var/www/html/kmls.txt');
      setState(() => _statusMessage = 'Orbit stopped.');
    } catch (e) {
      setState(() => _statusMessage = 'Error stopping orbit: $e');
    }
  }

  // ─── Validation helper ──────────────────────────────────────────────

  String? _validateDouble(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (double.tryParse(value) == null) return 'Enter a valid number';
    return null;
  }

  // ─── UI ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lgService = context.watch<LGService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Orbit Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Connection badge ─────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        lgService.isConnected
                            ? Icons.check_circle
                            : Icons.error,
                        color: lgService.isConnected
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lgService.isConnected
                            ? 'Connected to LG Rig'
                            : 'Not Connected (Demo Mode)',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Coordinate inputs ────────────────────────────────
              Text('Location', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: _validateDouble,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: _validateDouble,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _altController,
                      decoration: const InputDecoration(
                        labelText: 'Altitude (m)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: _validateDouble,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _rangeController,
                      decoration: const InputDecoration(
                        labelText: 'Range (m)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: _validateDouble,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Action buttons ───────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isOrbiting ? null : _startOrbit,
                      icon: const Icon(Icons.threesixty),
                      label: const Text('Start Orbit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _stopOrbit,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop Orbit'),
                    ),
                  ),
                ],
              ),

              // ── Status area ──────────────────────────────────────
              if (_isOrbiting) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
              if (_statusMessage != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          _statusMessage!.startsWith('Error')
                              ? Icons.error_outline
                              : Icons.info_outline,
                          color: _statusMessage!.startsWith('Error')
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(_statusMessage!),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
