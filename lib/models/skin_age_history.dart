class SkinAgeHistory {
  final String date;
  final int age;
  final int? change;

  SkinAgeHistory({
    required this.date,
    required this.age,
    this.change,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'age': age,
    'change': change,
  };

  factory SkinAgeHistory.fromJson(Map<String, dynamic> json) => SkinAgeHistory(
    date: json['date'],
    age: json['age'],
    change: json['change'],
  );
}
