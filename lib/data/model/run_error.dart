class RError {
  final String runId;
  final DateTime createdAt;
  final String id;
  final String errorType;
  final DateTime updatedAt;
  final String message;
  final String traceback;

  RError({
    required this.runId,
    required this.createdAt,
    required this.id,
    required this.errorType,
    required this.updatedAt,
    required this.message,
    required this.traceback,
  });

  factory RError.fromJson(Map<String, dynamic> json) {
    return RError(
      id: json['id'] as String,
      runId: json['run_id'] as String,
      errorType: json['error_type'] as String? ?? 'UnknownError',
      message: json['message'] as String? ?? '',
      traceback: json['traceback'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'run_id': runId,
      'error_type': errorType,
      'message': message,
      'traceback': traceback,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
