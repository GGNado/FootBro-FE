class PartitaCreateRequest {
  final DateTime dataOra;
  final String luogo;

  PartitaCreateRequest({
    required this.dataOra,
    required this.luogo,
  });

  factory PartitaCreateRequest.fromJson(Map<String, dynamic> json) {
    return PartitaCreateRequest(
      dataOra: DateTime.parse(json['dataOra']),
      luogo: json['luogo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dataOra': dataOra.toIso8601String(),
      'luogo': luogo,
    };
  }
}