import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_distribution/model/schedule.dart';

class ScheduleClient {
  final String backend;

  ScheduleClient(this.backend);

  Future<List<Schedule>> getSchedules() async {
    final url = Uri.parse("$backend/api/schedule");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      return [];
    }
    final Map<String, dynamic> responseJson = jsonDecode(response.body);
    final data = responseJson['data'];
    final List<Schedule> schedules = data
        .map<Schedule>((e) => Schedule.fromJson(e as Map<String, dynamic>))
        .toList();
    return schedules;
  }
}
