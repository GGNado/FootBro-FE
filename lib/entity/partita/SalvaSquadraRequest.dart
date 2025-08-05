class SalvaSquadraRequest {
  final List<int> idUtenti;
  final String squadra;

  SalvaSquadraRequest({
    required this.idUtenti,
    required this.squadra,
  });

  Map<String, dynamic> toJson() {
    return {
      'idUtenti': idUtenti,
      'squadra': squadra,
    };
  }

  factory SalvaSquadraRequest.fromJson(Map<String, dynamic> json) {
    return SalvaSquadraRequest(
      idUtenti: List<int>.from(json['idUtenti']),
      squadra: json['squadra'],
    );
  }
}