class QuickStatsResponse {
  final int partiteGiocateTotali;
  final int goalFattiTotali;
  final int assistTotali;

  QuickStatsResponse({
    required this.partiteGiocateTotali,
    required this.goalFattiTotali,
    required this.assistTotali,
  });

  factory QuickStatsResponse.fromJson(Map<String, dynamic> json) {
    return QuickStatsResponse(
      partiteGiocateTotali: json['partiteGiocateTotali'],
      goalFattiTotali: json['goalFattiTotali'],
      assistTotali: json['assistTotali'],
    );
  }
}