class Schedule {
  final String id;
  final String name;
  final dynamic parameters;
  final String? nextRunTime;
  final String startDate;
  final String endDate;
  final String status;

  Schedule({
    required this.id,
    required this.name,
    this.parameters,
    this.nextRunTime,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      name: json['name'] as String,
      parameters: json['parameters'] as dynamic,
      nextRunTime: json['next_run_time'] as String?,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      status: json['status'] as String,
    );
  }
}
