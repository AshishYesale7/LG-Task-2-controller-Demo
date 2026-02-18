import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_client/services/lg_service.dart';

/// Data-visualisation demo – recent earthquakes on Liquid Galaxy.
///
/// Fetches earthquake data from the USGS API (mocked for now),
/// displays it in a colour-coded card list, and lets students
/// push individual earthquake placemarks to the LG rig.
class EarthquakeScreen extends StatefulWidget {
  const EarthquakeScreen({super.key});

  @override
  State<EarthquakeScreen> createState() => _EarthquakeScreenState();
}

/// Lightweight model for a single earthquake event.
class _Earthquake {
  final String id;
  final String place;
  final double magnitude;
  final double latitude;
  final double longitude;
  final double depth;
  final DateTime time;

  const _Earthquake({
    required this.id,
    required this.place,
    required this.magnitude,
    required this.latitude,
    required this.longitude,
    required this.depth,
    required this.time,
  });
}

class _EarthquakeScreenState extends State<EarthquakeScreen> {
  bool _isLoading = false;
  String? _statusMessage;
  List<_Earthquake> _earthquakes = [];

  @override
  void initState() {
    super.initState();
    _fetchEarthquakes();
  }

  // ─── Mock data fetch ───────────────────────────────────────────────

  /// Simulates fetching earthquake data from the USGS GeoJSON feed.
  ///
  /// In a real app use:
  /// ```dart
  /// final url = Uri.parse(
  ///   'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson',
  /// );
  /// final response = await http.get(url);
  /// ```
  Future<void> _fetchEarthquakes() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      _earthquakes = [
        _Earthquake(
          id: 'eq1',
          place: '15 km SSW of Searles Valley, CA',
          magnitude: 5.4,
          latitude: 35.6895,
          longitude: -117.3880,
          depth: 10.5,
          time: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        _Earthquake(
          id: 'eq2',
          place: '80 km E of Hualien, Taiwan',
          magnitude: 6.1,
          latitude: 23.9749,
          longitude: 122.1688,
          depth: 25.0,
          time: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        _Earthquake(
          id: 'eq3',
          place: '12 km NNE of Tirana, Albania',
          magnitude: 4.2,
          latitude: 41.4275,
          longitude: 19.8189,
          depth: 8.0,
          time: DateTime.now().subtract(const Duration(hours: 8)),
        ),
        _Earthquake(
          id: 'eq4',
          place: '45 km S of Kermadec Islands, NZ',
          magnitude: 7.0,
          latitude: -30.2000,
          longitude: -177.3000,
          depth: 55.0,
          time: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        _Earthquake(
          id: 'eq5',
          place: '22 km W of Lleida, Spain',
          magnitude: 3.1,
          latitude: 41.6176,
          longitude: 0.3800,
          depth: 5.0,
          time: DateTime.now().subtract(const Duration(hours: 18)),
        ),
      ];
      _isLoading = false;
    });
  }

  // ─── Visualise on LG ──────────────────────────────────────────────

  /// Sends a placemark to the LG rig for the given earthquake.
  Future<void> _visualiseOnLG(_Earthquake eq) async {
    final lgService = context.read<LGService>();

    setState(() => _statusMessage = 'Sending ${eq.place}…');

    try {
      await lgService.sendKMLPlacemark(
        name: 'M${eq.magnitude} – ${eq.place}',
        latitude: eq.latitude,
        longitude: eq.longitude,
        description: 'Magnitude: ${eq.magnitude}\n'
            'Depth: ${eq.depth} km\n'
            'Time: ${eq.time.toLocal()}',
      );
      await lgService.flyTo(
        latitude: eq.latitude,
        longitude: eq.longitude,
        altitude: 500,
        range: 50000,
      );
      setState(() => _statusMessage = 'Visualised ${eq.place} on LG');
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────

  /// Returns a colour encoding the earthquake magnitude.
  Color _magnitudeColor(double mag) {
    if (mag >= 7.0) return Colors.red.shade700;
    if (mag >= 5.0) return Colors.orange.shade700;
    if (mag >= 4.0) return Colors.amber.shade700;
    return Colors.green.shade700;
  }

  /// How long ago the earthquake occurred, as a human-readable string.
  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }

  // ─── UI ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquake Visualiser'),
        actions: [
          IconButton(
            tooltip: 'Refresh data',
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchEarthquakes,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Status bar ─────────────────────────────────────────
          if (_isLoading) const LinearProgressIndicator(),
          if (_statusMessage != null)
            Container(
              width: double.infinity,
              color: _statusMessage!.startsWith('Error')
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Text(
                _statusMessage!,
                style: TextStyle(
                  color: _statusMessage!.startsWith('Error')
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),

          // ── Legend ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _legendDot(Colors.green.shade700, '< 4'),
                const SizedBox(width: 12),
                _legendDot(Colors.amber.shade700, '4 – 5'),
                const SizedBox(width: 12),
                _legendDot(Colors.orange.shade700, '5 – 7'),
                const SizedBox(width: 12),
                _legendDot(Colors.red.shade700, '≥ 7'),
              ],
            ),
          ),
          const Divider(),

          // ── Earthquake list ────────────────────────────────────
          Expanded(
            child: _earthquakes.isEmpty && !_isLoading
                ? const Center(child: Text('No earthquake data loaded.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _earthquakes.length,
                    itemBuilder: (context, index) {
                      final eq = _earthquakes[index];
                      return _buildEarthquakeCard(eq);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Builds a colour-coded card for a single earthquake event.
  Widget _buildEarthquakeCard(_Earthquake eq) {
    final magColor = _magnitudeColor(eq.magnitude);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Magnitude badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: magColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                eq.magnitude.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: magColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eq.place,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Depth: ${eq.depth} km  •  ${_timeAgo(eq.time)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            // Visualise button
            FilledButton.tonalIcon(
              onPressed: () => _visualiseOnLG(eq),
              icon: const Icon(Icons.satellite_alt, size: 18),
              label: const Text('LG'),
            ),
          ],
        ),
      ),
    );
  }

  /// Small coloured dot + label for the legend row.
  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
