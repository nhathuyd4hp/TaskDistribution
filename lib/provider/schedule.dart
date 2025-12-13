import 'package:flutter/foundation.dart';
import 'package:task_distribution/model/robot.dart';
import 'package:task_distribution/model/schedule.dart';
import 'package:task_distribution/provider/socket.dart';
import 'package:task_distribution/service/schedule.dart';

class ScheduleProvider extends ChangeNotifier {
  //
  final ScheduleClient repository;
  final ServerProvider server;
  List<Schedule> _schedules = [];
  bool _isLoading = false;
  String? _errorMessage;
  // Getter
  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // Constructor
  ScheduleProvider({required this.repository, required this.server});
  // bindServer
  Future<void> bindServer() async {
    if (server.status == ConnectionStatus.connecting) {
      _isLoading = true;
      _schedules = [];
    }
    if (server.status == ConnectionStatus.connected) {
      _isLoading = false;
      _errorMessage = null;
      _schedules = await repository.getSchedules();
    }
    if (server.status == ConnectionStatus.disconnected) {
      _isLoading = false;
      _errorMessage = server.errorMessage;
      _schedules = [];
    }
    notifyListeners();
  }

  Future<void> delete(Schedule schedule) async {
    final (success, message) = await repository.delete(schedule);
    if (success) {
      server.notification(message);
    } else {
      server.warning(message);
    }
  }

  Future<void> setSchedule(Robot robot, Map<String, String> schedule) async {
    if (schedule['day_of_week'] == "") {
      return;
    }
    final (success, message) = await repository.setSchedule(robot, schedule);
    if (success) {
      server.notification(message);
    } else {
      server.warning(message);
    }
  }
}
