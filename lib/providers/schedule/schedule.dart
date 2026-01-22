import 'package:flutter/foundation.dart';
import 'package:task_distribution/data/model/robot.dart';
import 'package:task_distribution/data/model/schedule.dart';
import 'package:task_distribution/providers/socket.dart';
import 'package:task_distribution/data/services/schedule.dart';

class ScheduleProvider extends ChangeNotifier {
  //
  final ScheduleClient repository;
  final ServerProvider server;
  List<Schedule> _schedules = [];
  // Getter
  List<Schedule> get schedules => _schedules;
  // Constructor
  ScheduleProvider({required this.repository, required this.server});
  // bindServer
  Future<void> bindServer() async {
    if (server.status == ConnectionStatus.connected) {
      _schedules = await repository.getSchedules();
    } else {
      _schedules = [];
    }
    notifyListeners();
  }

  Future<void> deleteSchedule(Schedule schedule) async {
    final bool success = await repository.delete(schedule);
    if (!success) {
      return server.notification("Xóa lịch trình `${schedule.name}` thất bại");
    }
    return server.notification("Xóa lịch trình `${schedule.name}` thành công");
  }

  Future<void> setSchedule(Robot robot, Map<String, String> schedule) async {
    if (schedule['day_of_week'] == null || schedule['day_of_week'] == "") {
      return server.notification(
        "${robot.name}: cần chọn ít nhất 1 ngày chạy.",
      );
    }
    final Schedule? record = await repository.setSchedule(robot, schedule);
    if (record == null) {
      return server.notification("Cài lịch cho ${robot.name} lỗi");
    }
    return server.notification("Cài lịch cho ${robot.name} thành công");
  }
}
