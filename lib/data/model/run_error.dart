class RError {
  final String runId;
  final DateTime createdAt;
  final String id;
  final String errorType;
  final DateTime? updatedAt;
  final String message;
  final String traceback;

  RError({
    required this.runId,
    required this.createdAt,
    required this.id,
    required this.errorType,
    this.updatedAt,
    required this.message,
    required this.traceback,
  });

  factory RError.fromJson(Map<String, dynamic> json) {
    return RError(
      runId: json['run_id'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      id: json['id'] as String? ?? '',
      errorType: json['error_type'] as String? ?? 'UnknownError',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      message: json['message'] as String? ?? '',
      traceback: json['traceback'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'run_id': runId,
      'created_at': createdAt.toIso8601String(),
      'id': id,
      'error_type': errorType,
      'updated_at': updatedAt?.toIso8601String(),
      'message': message,
      'traceback': traceback,
    };
  }
}
