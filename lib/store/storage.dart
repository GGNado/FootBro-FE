import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserJson(String userJson) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_data', userJson);
}

Future<String?> getUserJson() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_data');
}

Future<void> clearUserData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('user_data');
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('user_data');
  if (userJson == null) return null;

  final Map<String, dynamic> userMap = jsonDecode(userJson);
  return userMap['token'] as String?;
}