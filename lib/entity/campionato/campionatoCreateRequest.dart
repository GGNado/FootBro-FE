class CampionatoCreateRequest {
  final String nome;
  final String descrizione;
  final int idUtente;
  final String tipologiaCampionato;

  const CampionatoCreateRequest({
    required this.nome,
    required this.descrizione,
    required this.idUtente,
    required this.tipologiaCampionato,
  });

  // Conversione da JSON
  factory CampionatoCreateRequest.fromJson(Map<String, dynamic> json) {
    return CampionatoCreateRequest(
      nome: json['nome'] as String,
      descrizione: json['descrizione'] as String,
      idUtente: json['idUtente'] as int,
      tipologiaCampionato: json['tipologiaCampionato'] as String,
    );
  }

  // Conversione a JSON
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descrizione': descrizione,
      'idUtente': idUtente,
      'tipologiaCampionato': tipologiaCampionato,
    };
  }
}