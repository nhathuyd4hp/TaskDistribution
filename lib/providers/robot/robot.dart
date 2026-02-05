import 'package:flutter/foundation.dart';
import 'package:task_distribution/data/model/run.dart';
import 'package:task_distribution/data/services/robot.dart';
import 'package:task_distribution/providers/socket.dart';
import "../../data/model/robot.dart";

class RobotProvider extends ChangeNotifier {
  //
  final RobotClient repository;
  final ServerProvider server;
  List<Robot> _robots = [];
  // Getter
  List<Robot> get robots => _robots;
  // Constructor
  RobotProvider({required this.server, required this.repository});
  // bindServer
  Future<void> bindServer() async {
    if (server.status == ConnectionStatus.connected) {
      _robots = await repository.getRobots();
    } else {
      _robots = [];
    }
    notifyListeners();
  }

  Future<void> reload() async {
    _robots = await repository.getRobots();
    notifyListeners();
  }

  Future<void> run(Map<String, dynamic> parameters) async {
    final Run? run = await repository.run(parameters);
    if (run != null) return server.reload();
    server.error("Khởi chạy ${parameters['name']} thất bại");
  }
}
