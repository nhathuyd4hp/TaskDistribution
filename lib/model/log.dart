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

  static final RegExp _extendedLogRegex = RegExp(
    r'^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}[,.]\d+)\s+-\s+.*?\s+-\s+([A-Z]+)\s+-\s+(.*)$',
  );

  static final RegExp _standardLogRegex = RegExp(
    r'^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}[,.]\d+)\s+-\s+([A-Z]+)\s+-\s+(.*)$',
  );

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(
        json['timestamp'].toString().replaceAll(',', '.'),
      ),
      level: json['level'] as String,
      message: json['message'] as String,
    );
  }

  factory LogEntry.fromRawLine(String line) {
    final trimmed = line.trim();

    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final Map<String, dynamic> json = jsonDecode(trimmed);
        return LogEntry.fromJson(json);
      } catch (_) {}
    }

    var match = _extendedLogRegex.firstMatch(trimmed);
    if (match != null) {
      try {
        return LogEntry(
          timestamp: DateTime.parse(match.group(1)!.replaceAll(',', '.')),
          level: match.group(2)!,
          message: match.group(3)!,
        );
      } catch (_) {}
    }

    match = _standardLogRegex.firstMatch(trimmed);
    if (match != null) {
      try {
        return LogEntry(
          timestamp: DateTime.parse(match.group(1)!.replaceAll(',', '.')),
          level: match.group(2)!,
          message: match.group(3)!,
        );
      } catch (_) {}
    }

    // 4️⃣ Fallback
    return LogEntry(timestamp: DateTime.now(), level: "INFO", message: trimmed);
  }
}
