import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_distribution/model/robot.dart';
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

  Future<(bool, String)> delete(Schedule schedule) async {
    try {
      final url = Uri.parse("$backend/api/schedule/${schedule.id}");
      final response = await http.delete(url);
      if (response.statusCode != 200) {
        return (false, "Thất bại");
      }
      return (true, "Thành công");
    } catch (e) {
      return (false, e.toString());
    }
  }

  Future<(bool, String)> setSchedule(
    Robot robot,
    Map<String, dynamic>? schedule,
  ) async {
    try {
      final url = Uri.parse("$backend/api/schedule");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": robot.name, "schedule": schedule}),
      );
      if (response.statusCode != 201) {
        return (false, "Thất bại");
      }
      return (true, "Thành công");
    } catch (e) {
      return (false, e.toString());
    }
  }
}
