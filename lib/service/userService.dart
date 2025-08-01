import 'dart:convert';

import 'package:foot_bro/entity/statistiche/quickStatsResponse.dart';
import 'package:http/http.dart' as http;

import 'HTTP_URL.dart';

class UserService {
  final String _baseUrl = HTTP_URLS.host;

  Future<QuickStatsResponse> getQuickStats(String token, int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/utenti/$id/quickStats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return QuickStatsResponse.fromJson(data);
    } else {
      throw Exception('Errore durante il fetch dei quick stats: ${response.statusCode}');
    }
  }
}