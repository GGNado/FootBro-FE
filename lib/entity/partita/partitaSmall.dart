class PartitaSmall {
  final int id;
  final String luogo;
  final DateTime dataOra;

  PartitaSmall({
    required this.id,
    required this.luogo,
    required this.dataOra,
  });

  factory PartitaSmall.fromJson(Map<String, dynamic> json) {
    return PartitaSmall(
      id: json['id'],
      luogo: json['luogo'],
      dataOra: DateTime.parse(json['dataOra']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'luogo': luogo,
      'dataOra': dataOra.toIso8601String(),
    };
  }
}
