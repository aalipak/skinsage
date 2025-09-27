class HealthScoreHistory {
  final String date;
  final double score;
  final double? change;

  HealthScoreHistory({
    required this.date,
    required this.score,
    this.change,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'score': score,
    'change': change,
  };

  factory HealthScoreHistory.fromJson(Map<String, dynamic> json) => HealthScoreHistory(
    date: json['date'],
    score: json['score'],
    change: json['change'],
  );
} 