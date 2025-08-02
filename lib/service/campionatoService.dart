import '../entity/campionato/campionatoResponse.dart';
import '../entity/statistiche/classificaResponse.dart';
import 'HTTP_URL.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class CampionatoService {
  final String _baseUrl = HTTP_URLS.host;

  Future<List<CampionatoResponse>> getCampionati(String token, int id) async {
    final response = await http.get(
      Uri.parse(_baseUrl + "/api/campionati/iscritto/${id}"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['campionatoFindAllDTO'];
      return data.map((json) => CampionatoResponse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load campionati');
    }
  }

  Future<bool> joinCampionato(String token, int id, String code) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl + "/api/campionati/join"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'codice': code,
          'idUtente': id,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Campionato non trovato');
      } else if (response.statusCode == 409) {
        throw Exception('Sei già iscritto a questo campionato');
      } else if (response.statusCode == 403) {
        throw Exception('Non puoi accedere a questo campionato');
      } else {
        throw Exception('Errore durante l\'accesso al campionato');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Errore di connessione');
    }
  }

  Future<ClassificaResponse> getClassifica(String token, int campionatoId) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/api/campionati/$campionatoId/classifica"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return ClassificaResponse.fromJson(decoded);
    } else {
      throw Exception('Errore nel recupero della classifica');
    }
  }

}