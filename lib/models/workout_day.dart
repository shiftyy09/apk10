import 'exercise.dart';

class WorkoutDay {
  String name;
  DateTime date;
  List<Exercise> exercises;

  WorkoutDay({required this.name, required this.date, required this.exercises});

  Map<String, dynamic> toJson() => {
        'name': name,
        'date': date.toIso8601String(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  static WorkoutDay fromJson(Map<String, dynamic> json) => WorkoutDay(
        name: json['name'],
        date: DateTime.parse(json['date']),
        exercises: (json['exercises'] as List<dynamic>)
            .map((e) => Exercise.fromJson(e))
            .toList(),
      );
}
