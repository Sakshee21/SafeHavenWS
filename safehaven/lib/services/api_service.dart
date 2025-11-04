import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  static Future<Map<String, dynamic>> createCase(double latitude, double longitude) async {
    final res = await http.post(
      Uri.parse('$baseUrl/cases/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'latitude': latitude.toString(), 'longitude': longitude.toString()}),
    );
    if (res.statusCode != 200) throw Exception('Failed to create case: ${res.body}');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getCase(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/cases/$id'));
    if (res.statusCode != 200) throw Exception('Failed to get case: ${res.body}');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getNearbyCases(double lat, double lng, {double radiusKm = 10}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/cases/nearby?lat=$lat&lng=$lng&radiusKm=$radiusKm'),
    );
    if (res.statusCode != 200) throw Exception('Failed to get nearby cases: ${res.body}');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> volunteerAccept(int caseId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/volunteers/accept/$caseId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 200) throw Exception('Failed to accept: ${res.body}');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> volunteerReport(int caseId, String text) async {
    final res = await http.post(
      Uri.parse('$baseUrl/volunteers/report/$caseId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
    if (res.statusCode != 200) throw Exception('Failed to submit report: ${res.body}');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getStats() async {
    final res = await http.get(Uri.parse('$baseUrl/stats'));
    if (res.statusCode != 200) throw Exception('Failed to get stats: ${res.body}');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getUserCases(String userAddress) async {
    final res = await http.get(Uri.parse('$baseUrl/cases/user/$userAddress'));
    if (res.statusCode != 200) throw Exception('Failed to get user cases: ${res.body}');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> markFalseAlarm(int caseId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/cases/markFalseAlarm/$caseId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 200) throw Exception('Failed to mark false alarm: ${res.body}');
    return jsonDecode(res.body);
  }
}

