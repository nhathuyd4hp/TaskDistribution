class Schedule {
  final String id;
  final String name;
  final dynamic parameters;
  final DateTime? nextRunTime;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;

  Schedule({
    required this.id,
    required this.name,
    this.parameters,
    this.nextRunTime,
    this.startDate,
    this.endDate,
    required this.status,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      name: json['name'] as String,
      parameters: json['parameters'] as dynamic,
      nextRunTime: json['next_run_time'] != null
          ? DateTime.parse(json['next_run_time']).toLocal()
          : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      status: json['status'] as String,
    );
  }
}
