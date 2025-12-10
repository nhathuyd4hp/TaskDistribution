import 'package:flutter/widgets.dart';

class Run {
  final String id;
  final String robot;
  final String status;
  final String? parameters;
  final String? result;
  final String createdAt;
  final String? updatedAt;

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
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
