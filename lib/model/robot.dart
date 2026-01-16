import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:task_distribution/main.dart';

class Parameter {
  final String name;
  final dynamic defaultValue;
  final bool required;
  String annotation;

  Parameter({
    required this.name,
    required this.required,
    required this.annotation,
    this.defaultValue,
  });

  factory Parameter.fromJson(Map<String, dynamic> json) {
    return Parameter(
      name: json['name'] as String,
      defaultValue: json['default'],
      required: json['required'] as bool,
      annotation: json['annotation'] as String,
    );
  }

  void setAnnotation(String annotation) {
    this.annotation = annotation;
  }
}

class Robot {
  final String name;
  final bool active;
  final List<Parameter> parameters;

  Robot({required this.name, required this.active, required this.parameters});

  factory Robot.fromJson(Map<String, dynamic> json) {
    return Robot(
      name: json['name'] as String,
      active: json['active'] as bool,
      parameters: (json['parameters'] as List<dynamic>)
          .map((e) => Parameter.fromJson(e))
          .toList(),
    );
  }

  Future<Robot> reGenerate() async {
    bool hasAPI = parameters.any(
      (param) => param.annotation.toLowerCase().contains("type.api"),
    );
    if (!hasAPI) return this;

    for (int i = 0; i < parameters.length; i++) {
      Parameter parameter = parameters[i];
      if (!parameter.annotation.toLowerCase().contains("type.api")) continue;
      if (parameter.defaultValue == null) {
        throw Exception(
          "Cannot build form: parameter '${parameter.name}' does not have a default value.",
        );
      }
      final url = Uri.parse(
        "${RobotAutomation.backendUrl}${parameter.defaultValue}",
      );
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception("Cannot build form: ${response.body}");
      }
      final responseJson = jsonDecode(response.body);
      parameter.setAnnotation(responseJson['data']!);
    }
    return this;
  }
}
