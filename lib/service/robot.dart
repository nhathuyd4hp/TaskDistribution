import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_distribution/model/robot.dart';

class RobotClient {
  final String backend;

  RobotClient(this.backend);

  Future<List<Robot>> getRobots() async {
    final url = Uri.parse("$backend/api/robots");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      return [];
    }
    final Map<String, dynamic> responseJson = jsonDecode(response.body);
    final data = responseJson['data'];
    final List<Robot> robots = data
        .map<Robot>((e) => Robot.fromJson(e as Map<String, dynamic>))
        .toList();
    return robots;
  }
}
