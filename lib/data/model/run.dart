import 'package:fluent_ui/fluent_ui.dart';

class Run {
  final String id;
  final String robot;
  final String status;
  final String? parameters;
  final String? result;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Run({
    required this.id,
    required this.robot,
    required this.status,
    this.parameters,
    this.result,
    required this.createdAt,
    this.updatedAt,
  });

  factory Run.fromJson(Map<String, dynamic> json) {
    return Run(
      id: json['id'] as String,
      robot: json['robot'] as String,
      status: json['status'] as String,
      parameters: json['parameters'] as String?,
      result: json['result'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Color getColor() {
    if (status == "FAILURE") {
      return Color(0xfffeebeb);
    }
    if (status == "PENDING") {
      return Color(0xffecfaf4);
    }
    return Color(0xffeff7ff);
  }
}
