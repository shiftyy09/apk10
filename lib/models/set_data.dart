class SetData {
  double weight;
  int reps;

  SetData({required this.weight, required this.reps});

  Map<String, dynamic> toJson() => {
        'weight': weight,
        'reps': reps,
      };

  static SetData fromJson(Map<String, dynamic> json) => SetData(
        weight: (json['weight']).toDouble(),
        reps: json['reps'],
      );
}
