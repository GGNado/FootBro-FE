import 'package:foot_bro/entity/user/userCampionatoResponse.dart';

class Partita {
  final int id;
  final String luogo;
  final DateTime dataOra;
  final int golSquadraB;
  final int golSquadraA;
  final List<PartecipazionePartita> partecipazioni;

  Partita({
    required this.id,
    required this.luogo,
    required this.dataOra,
    required this.golSquadraB,
    required this.golSquadraA,
    required this.partecipazioni,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'luogo': luogo,
      'dataOra': dataOra.toIso8601String(),
      'golSquadraB': golSquadraB,
      'golSquadraA': golSquadraA,
      'partecipazioni': partecipazioni.map((p) => p.toJson()).toList(),
    };
  }

  factory Partita.fromJson(Map<String, dynamic> json) {
    return Partita(
      id: json['id'],
      luogo: json['luogo'],
      golSquadraB: json['golSquadraB'] ?? 0,
      golSquadraA: json['golSquadraA'] ?? 0,
      dataOra: DateTime.parse(json['dataOra']),
      partecipazioni: (json['partecipazioni'] as List)
          .map((p) => PartecipazionePartita.fromJson(p))
          .toList(),
    );
  }
}

class PartecipazionePartita {
  final UserCampionatoResponse utente;
  final int golSegnati;
  final int assist;
  final double voto;
  final String squadra;

  PartecipazionePartita({
    required this.utente,
    required this.golSegnati,
    required this.assist,
    required this.voto,
    required this.squadra,
  });

  factory PartecipazionePartita.fromJson(Map<String, dynamic> json) {
    return PartecipazionePartita(
      utente: UserCampionatoResponse.fromJson(json['utente']),
      golSegnati: json['golSegnati'] ?? 0,
      assist: json['assist'] ?? 0,
      voto: json['voto'] ?? 0,
      squadra: json['squadra'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'utente': utente.toJson(),
      'golSegnati': golSegnati,
      'assist': assist,
      'voto': voto,
      'squadra': squadra,
    };
  }
}