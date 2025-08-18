import 'set_data.dart';

class Exercise {
  String name;
  List<SetData> sets;
  String tip;

  Exercise({required this.name, List<SetData>? sets, this.tip = ''})
      : sets = sets ?? [];

  double? get previousWeight => sets.isNotEmpty ? sets.last.weight : null;

  Map<String, dynamic> toJson() => {
        'name': name,
        'tip': tip,
        'sets': sets.map((e) => e.toJson()).toList(),
      };

  static Exercise fromJson(Map<String, dynamic> json) => Exercise(
        name: json['name'],
        tip: json['tip'] ?? '',
        sets: (json['sets'] as List<dynamic>)
            .map((e) => SetData.fromJson(e))
            .toList(),
      );
}
