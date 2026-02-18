import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for fetching earthquake data from the USGS API.
///
/// Uses the USGS Earthquake Hazards Program real-time feeds.
/// Docs: https://earthquake.usgs.gov/fdsnws/event/1/
class EarthquakeService {
  static const String _baseUrl =
      'https://earthquake.usgs.gov/fdsnws/event/1/query';

  /// Fetch recent earthquakes above a minimum magnitude.
  Future<List<Map<String, dynamic>>> fetchRecentEarthquakes({
    double minMagnitude = 4.0,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?format=geojson&limit=$limit&minmagnitude=$minMagnitude&orderby=time',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final features = data['features'] as List;
        return features.map((f) {
          final props = f['properties'] as Map<String, dynamic>;
          final coords = f['geometry']['coordinates'] as List;
          return {
            'title': props['title'] ?? 'Unknown',
            'magnitude': (props['mag'] as num?)?.toDouble() ?? 0.0,
            'place': props['place'] ?? 'Unknown location',
            'time': DateTime.fromMillisecondsSinceEpoch(props['time'] as int),
            'longitude': (coords[0] as num).toDouble(),
            'latitude': (coords[1] as num).toDouble(),
            'depth': (coords[2] as num).toDouble(),
            'url': props['url'] ?? '',
          };
        }).toList();
      }
    } catch (e) {
      // Error fetching earthquake data — caller should handle empty list
      debugPrint('Earthquake API error: $e');
    }
    return [];
  }
}
