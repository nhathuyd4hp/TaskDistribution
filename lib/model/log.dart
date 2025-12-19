import 'dart:convert';

class LogEntry {
  final DateTime timestamp;
  final String level;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp'].replaceAll(',', '.')),
      level: json['level'] as String,
      message: json['message'] as String,
    );
  }

  factory LogEntry.fromRawLine(String line) {
    final Map<String, dynamic> json = jsonDecode(line);
    return LogEntry.fromJson(json);
  }
}
