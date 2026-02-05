import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:task_distribution/main.dart';

class Parameter {
  final String name;
  dynamic defaultValue;
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

  void setDefaultValue(dynamic defaultValue) {
    this.defaultValue = defaultValue;
  }
}

class Robot {
  final String name;
  final bool active;
  List<Parameter> parameters;

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
      (param) =>
          param.annotation.toLowerCase().contains("src.core.type.api") &&
          param.defaultValue.toString().startsWith("/api/type"),
    );
    if (!hasAPI) return this;

    for (int i = 0; i < parameters.length; i++) {
      Parameter parameter = parameters[i];
      if (!(parameter.annotation.toLowerCase().contains("src.core.type.api") &&
          parameter.defaultValue.toString().startsWith("/api/type"))) {
        continue;
      }
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
      // Set Annotation
      parameter.setAnnotation(responseJson['data']!);
      // Set Default Value for Asset
      if (parameter.annotation.toLowerCase().contains("src.core.type.asset")) {
        final content = parameter.annotation.substring(
          parameter.annotation.indexOf('[') + 1,
          parameter.annotation.lastIndexOf(']'),
        );
        final List<dynamic> items = content.split(',').map((e) {
          String clean = e.trim().replaceAll("'", "").replaceAll('"', "");
          return int.tryParse(clean) ?? clean;
        }).toList();
        if (items.isNotEmpty && items.first != "") {
          final uri = Uri.parse(parameter.defaultValue);
          final bucket = uri.queryParameters['bucket'];
          final objectName = uri.queryParameters['objectName'];
          parameter.setDefaultValue(
            '${bucket?.toLowerCase()}?objectName=$objectName',
          );
        }
      } else {
        final content = parameter.annotation.substring(
          parameter.annotation.indexOf('[') + 1,
          parameter.annotation.lastIndexOf(']'),
        );
        final List<dynamic> items = content.split(',').map((e) {
          String clean = e.trim().replaceAll("'", "").replaceAll('"', "");
          return int.tryParse(clean) ?? clean;
        }).toList();
        if (items.isNotEmpty && items.first != "") {
          parameter.setDefaultValue(items[0]);
        }
      }
    }
    return await reGenerate();
  }
}
