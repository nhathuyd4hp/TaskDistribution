import 'dart:convert';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:task_distribution/model/api_response.dart';
import 'package:task_distribution/model/run.dart';

class RunClient {
  final String backend;

  RunClient(this.backend);

  Future<List<Run>> getRuns() async {
    final url = Uri.parse("$backend/api/runs");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      return [];
    }
    final Map<String, dynamic> responseJson = jsonDecode(response.body);

    final apiResponse = APIResponse<List<Run>>.fromJson(
      responseJson,
      (data) => (data as List<dynamic>)
          .map((item) => Run.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    return apiResponse.data ?? [];
  }

  // Future<Run?> getRun(String id) async {
  //   final url = Uri.parse("$backend/api/runs/$id");
  //   final response = await http.get(url);
  //   if (response.statusCode != 200) {
  //     return null;
  //   }
  //   final Map<String, dynamic> responseJson = jsonDecode(response.body);

  //   final apiResponse = APIResponse<Run>.fromJson(
  //     responseJson,
  //     (data) => Run.fromJson(data as Map<String, dynamic>),
  //   );
  //   return apiResponse.data;
  // }

  Future<bool> result({required Run run, required String savePath}) async {
    if (run.result == null) return false;
    // Tách chuỗi
    final List<String> parts = run.result!.split('/');
    final String bucket = parts[0];
    final String objectName = parts.sublist(1).join("/");
    // Call API
    final url = Uri.parse("$backend/api/assets/$bucket?objectName=$objectName");
    final response = await http.get(url);
    if (response.statusCode != 200) return false;
    // Save
    final String filePath = p.join(savePath, p.basename(run.result!));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return true;
  }
}
