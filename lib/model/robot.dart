class Parameters {
  final String name;
  final dynamic defaultValue;
  final bool required;
  final String annotation;

  Parameters({
    required this.name,
    required this.required,
    required this.annotation,
    this.defaultValue,
  });

  factory Parameters.fromJson(Map<String, dynamic> json) {
    return Parameters(
      name: json['name'] as String,
      defaultValue: json['default'],
      required: json['required'] as bool,
      annotation: json['annotation'] as String,
    );
  }
}

class Robot {
  final String name;
  final bool active;
  final List<Parameters> parameters;

  Robot({required this.name, required this.active, required this.parameters});

  factory Robot.fromJson(Map<String, dynamic> json) {
    return Robot(
      name: json['name'] as String,
      active: json['active'] as bool,
      parameters: (json['parameters'] as List<dynamic>)
          .map((e) => Parameters.fromJson(e))
          .toList(),
    );
  }
}
