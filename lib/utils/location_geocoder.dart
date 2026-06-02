import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

/// Resolves coordinates from destination [location] text (no Firestore schema change).
class LocationGeocoder {
  static const LatLng indonesiaCenter = LatLng(-2.5489, 118.0149);

  static const Map<String, LatLng> _knownPlaces = {
    'bali': LatLng(-8.4095, 115.1889),
    'denpasar': LatLng(-8.6705, 115.2126),
    'jakarta': LatLng(-6.2088, 106.8456),
    'yogyakarta': LatLng(-7.7956, 110.3695),
    'jogja': LatLng(-7.7956, 110.3695),
    'bandung': LatLng(-6.9175, 107.6191),
    'surabaya': LatLng(-7.2575, 112.7521),
    'lombok': LatLng(-8.5650, 116.3512),
    'raja ampat': LatLng(-0.5000, 130.7500),
    'komodo': LatLng(-8.5569, 119.4327),
    'labuan bajo': LatLng(-8.4961, 119.8877),
    'borobudur': LatLng(-7.6079, 110.2038),
    'bromo': LatLng(-7.9425, 112.9530),
    'ijen': LatLng(-8.0580, 114.2420),
    'toraja': LatLng(-3.0457, 119.8808),
    'lake toba': LatLng(2.6880, 98.8788),
    'danau toba': LatLng(2.6880, 98.8788),
    'medan': LatLng(3.5952, 98.6722),
    'ubud': LatLng(-8.5069, 115.2625),
    'seminyak': LatLng(-8.6912, 115.1682),
  };

  static Future<LatLng> resolve(String location) async {
    final trimmed = location.trim();
    if (trimmed.isEmpty) return indonesiaCenter;

    final lower = trimmed.toLowerCase();
    for (final entry in _knownPlaces.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }

    try {
      final results = await locationFromAddress('$trimmed, Indonesia');
      if (results.isNotEmpty) {
        final first = results.first;
        return LatLng(first.latitude, first.longitude);
      }
    } catch (_) {
      // Fall through to country center.
    }

    return indonesiaCenter;
  }
}
