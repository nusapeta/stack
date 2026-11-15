// Minimal route client for Flutter. No Google Maps dependency: decode the
// base64 polyline and hand the points to any map widget.
import 'dart:convert';

import 'package:http/http.dart' as http;

class LatLng {
  const LatLng(this.lat, this.lng);
  final double lat;
  final double lng;
}

class RouteResult {
  RouteResult(this.distanceM, this.durationS, this.points);
  final int distanceM;
  final double durationS;
  final List<LatLng> points;
}

Future<RouteResult> fetchRoute({
  required String baseUrl,
  required LatLng from,
  required LatLng to,
  String profile = 'mobil',
  String apiKey = '',
}) async {
  final uri = Uri.parse('$baseUrl/route').replace(queryParameters: {
    'from': '${from.lat},${from.lng}',
    'to': '${to.lat},${to.lng}',
    'format': 'polyline',
    'profile': profile,
    if (apiKey.isNotEmpty) 'api_key': apiKey,
  });
  final res = await http.get(uri);
  if (res.statusCode != 200) {
    throw StateError('route failed: ${res.statusCode} ${res.body}');
  }
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  final encoded = utf8.decode(base64Decode(body['polyline_b64'] as String));
  return RouteResult(
    body['distance_m'] as int,
    (body['duration_s'] as num).toDouble(),
    decodePolyline(encoded),
  );
}

List<LatLng> decodePolyline(String encoded) {
  final points = <LatLng>[];
  var index = 0;
  var lat = 0;
  var lng = 0;
  while (index < encoded.length) {
    var shift = 0;
    var result = 0;
    int b;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

    points.add(LatLng(lat / 1e5, lng / 1e5));
  }
  return points;
}
