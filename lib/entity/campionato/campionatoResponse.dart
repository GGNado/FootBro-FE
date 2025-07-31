import 'package:foot_bro/entity/user/userCampionatoResponse.dart';

import '../user/user.dart';

class CampionatoResponse {
  final int id;
  final String nome;
  final String descrizione;
  final String codice;
  final UserCampionatoResponse creatore;

  CampionatoResponse({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.codice,
    required this.creatore,
  });

  factory CampionatoResponse.fromJson(Map<String, dynamic> json) {
    return CampionatoResponse(
      id: json['id'],
      nome: json['nome'],
      descrizione: json['descrizione'],
      codice: json['codice'],
      creatore: UserCampionatoResponse.fromJson(json['creatore']),
    );
  }
}