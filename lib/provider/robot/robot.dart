import 'package:flutter/foundation.dart';
import 'package:task_distribution/model/run.dart';
import 'package:task_distribution/service/robot.dart';
import 'package:task_distribution/provider/socket.dart';
import "../../model/robot.dart";

class RobotProvider extends ChangeNotifier {
  //
  final RobotClient repository;
  final ServerProvider server;
  List<Robot> _robots = [];
  bool _isLoading = false;
  String? _errorMessage;
  // Getter
  List<Robot> get robots => _robots;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // Constructor
  RobotProvider({required this.server, required this.repository});
  // bindServer
  Future<void> bindServer() async {
    if (server.status == ConnectionStatus.connecting) {
      _isLoading = true;
      _errorMessage = null;
      _robots = [];
    }
    if (server.status == ConnectionStatus.connected) {
      _isLoading = false;
      _errorMessage = null;
      _robots = await repository.getRobots();
    }
    if (server.status == ConnectionStatus.disconnected) {
      _isLoading = false;
      _errorMessage = server.errorMessage;
      _robots = [];
    }
    notifyListeners();
  }

  Future<void> run(Map<String, dynamic> parameters) async {
    final Run? run = await repository.run(parameters);
    if (run != null) {
      server.notification("Yêu cầu thành công");
    } else {
      server.notification("Yêu cầu thất bại");
    }
  }
}
