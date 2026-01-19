class APIResponse<T> {
  final bool success;
  final String message;
  final T? data;
  APIResponse({required this.success, required this.message, this.data});

  factory APIResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return APIResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}
