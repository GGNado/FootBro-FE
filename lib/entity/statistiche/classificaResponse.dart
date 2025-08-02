import 'package:foot_bro/entity/user/userCampionatoResponse.dart';

import '../user/user.dart';

class ClassificaResponse {
  final List<Partecipazione> partecipazioni;

  ClassificaResponse({required this.partecipazioni});

  factory ClassificaResponse.fromJson(Map<String, dynamic> json) {
    return ClassificaResponse(
      partecipazioni: (json['partecipazioni'] as List)
          .map((p) => Partecipazione.fromJson(p))
          .toList(),
    );
  }
}

class Partecipazione {
  final int id;
  final UserCampionatoResponse utente;
  final int punti;
  final int golFatti;
  final int assist;
  final int partiteGiocate;
  final int partiteVinte;
  final int partitePerse;
  final int partitePareggiate;
  final double mediaVoto;

  Partecipazione({
    required this.id,
    required this.utente,
    required this.punti,
    required this.golFatti,
    required this.assist,
    required this.partiteGiocate,
    required this.partiteVinte,
    required this.partitePerse,
    required this.partitePareggiate,
    required this.mediaVoto,
  });

  factory Partecipazione.fromJson(Map<String, dynamic> json) {
    return Partecipazione(
      id: json['id'],
      utente: UserCampionatoResponse.fromJson(json['utente']),
      punti: json['punti'] ?? -1,
      golFatti: json['golFatti'] ?? -1,
      assist: json['assist'] ?? -1,
      partiteGiocate: json['partiteGiocate'] ?? -1,
      partiteVinte: json['partiteVinte'] ?? -1,
      partitePerse: json['partitePerse'] ?? -1,
      partitePareggiate: json['partitePareggiate'] ?? -1,
      mediaVoto: (json['mediaVoto'] ?? -1).toDouble(),
    );
  }
}