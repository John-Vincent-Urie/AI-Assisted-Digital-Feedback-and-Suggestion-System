import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';

class ApiService {
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/auth/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'display_name': displayName,
      }),
    );
    return _decode(response);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(response);
  }

  static Future<Map<String, dynamic>> analyzeMood({
    required String text,
    String? userEmail,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/mood/analyze');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text, 'user_email': userEmail}),
    );
    return _decode(response);
  }

  static Future<Map<String, dynamic>> generateRecommendations({
    String? emotion,
    String? text,
    String? userEmail,
    String? spotifyAccessToken,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/recommendations/generate');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'emotion': emotion,
        'text': text,
        'user_email': userEmail,
        'spotify_access_token': spotifyAccessToken,
      }),
    );
    return _decode(response);
  }

  static Future<Map<String, dynamic>> recommendationHistory({String? userEmail}) async {
    final query = userEmail == null || userEmail.isEmpty
        ? ''
        : '?user_email=${Uri.encodeQueryComponent(userEmail)}';
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/recommendations/history$query');
    final response = await http.get(uri);
    return _decode(response);
  }

  static Future<Map<String, dynamic>> adminDashboard() async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/admin/dashboard');
    final response = await http.get(uri);
    return _decode(response);
  }

  static Future<Map<String, dynamic>> moodDistribution() async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/analytics/mood-distribution');
    final response = await http.get(uri);
    return _decode(response);
  }

  static Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body as Map<String, dynamic>;
    }

    final detail = (body is Map<String, dynamic>) ? body['detail'] : null;
    throw Exception(detail?.toString() ?? 'Request failed (${response.statusCode}).');
  }
}
