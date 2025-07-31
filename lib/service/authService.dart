import 'dart:convert';
import 'package:foot_bro/service/HTTP_URL.dart';
import 'package:foot_bro/store/storage.dart';
import 'package:http/http.dart' as http;

import '../entity/user/userAuthRequest.dart';
import '../entity/user/userAuthResponse.dart';

class AuthService {
  final String _baseUrl = HTTP_URLS.host;

  Future<UserAuthResponse> login(UserAuthRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/signin'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final json = response.body;
      await saveUserJson(json);
      return UserAuthResponse.fromJson(jsonDecode(json));
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  Future<bool> validateToken(String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/validate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}