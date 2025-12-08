import 'package:flutter/foundation.dart';
import 'package:task_distribution/service/robot.dart';
import 'package:task_distribution/provider/socket.dart';
import "../model/robot.dart";

class RobotProvider extends ChangeNotifier {
  //
  final RobotClient repository;
  List<Robot> _robots = [];
  bool _isLoading = false;
  String? _errorMessage;
  // Getter
  List<Robot> get robots => _robots;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // Constructor
  RobotProvider(this.repository);
  // bindServer
  Future<void> bindServer(ServerProvider server) async {
    if (server.status == ConnectionStatus.connecting) {
      _isLoading = true;
      _robots = [];
    }
    if (server.status == ConnectionStatus.connected) {
      _isLoading = false;
      _robots = await repository.getRobots();
    }
    if (server.status == ConnectionStatus.disconnected) {
      _isLoading = false;
      _errorMessage = server.errorMessage;
      _robots = [];
    }
    notifyListeners();
  }
}
