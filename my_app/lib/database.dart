

class OneFood {
  final String label;
  final double calories;
  final bool works;
  var time = new DateTime.now();
//OneFood FIGURE OUT IF THIS DEFAULT PARAMETER THING BREAKS
  OneFood({this.label, this.calories, this.works, this.time});

  factory OneFood.fromJson(Map<String, dynamic> json, bool found) {
    if (found) {
      return OneFood(
        label: json['hints'][0]['food']['label'],
        calories: json['hints'][0]['food']['nutrients']['ENERC_KCAL'],
        works: found,
      );
    } else {
      return OneFood(
        label: 'no',
        calories: 0.0,
        works: found,
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': time,
      'label': label,
      'calories': calories,
      'time': time,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Food{time: $time, name: $label, calories: $calories}';
  }
}
