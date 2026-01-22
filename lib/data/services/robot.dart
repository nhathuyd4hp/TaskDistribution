import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_distribution/data/model/api_response.dart';
import 'package:task_distribution/data/model/robot.dart';
import 'package:task_distribution/data/model/run.dart';

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

  Future<Run?> run(Map<String, dynamic> parameters) async {
    final url = Uri.parse("$backend/api/robots/run");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parameters),
    );
    if (response.statusCode != 200) {
      return null;
    }
    Map<String, dynamic> responseJson = jsonDecode(response.body);
    final apiResponse = APIResponse<Run>.fromJson(
      responseJson,
      (data) => Run.fromJson(data as Map<String, dynamic>),
    );
    return apiResponse.data;
  }
}
