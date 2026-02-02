class Run {
  final String id;
  final String robot;
  final String status;
  final String? parameters;
  final String? result;
  final DateTime createdAt;
  final DateTime? runAt;
  final DateTime? updatedAt;

  Run({
    required this.id,
    required this.robot,
    required this.status,
    this.parameters,
    this.result,
    required this.createdAt,
    this.runAt,
    this.updatedAt,
  });

  factory Run.fromJson(Map<String, dynamic> json) {
    return Run(
      id: json['id'] as String,
      robot: json['robot'] as String,
      status: json['status'] as String,
      parameters: json['parameters'] as String?,
      result: json['result'] as String?,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      runAt: json['run_at'] != null
          ? DateTime.parse(json['run_at']).toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : null,
    );
  }
}
