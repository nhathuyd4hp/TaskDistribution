import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:task_distribution/data/model/run.dart';
import 'package:task_distribution/data/model/run_error.dart';
import 'package:task_distribution/providers/socket.dart';
import 'package:task_distribution/data/services/run.dart';

class RunProvider extends ChangeNotifier {
  //
  final RunClient repository;
  final ServerProvider server;
  List<Run> _runs = [];
  // Getter
  List<Run> get runs => _runs;
  // Constructor
  RunProvider({required this.repository, required this.server});
  // bindServer
  Future<void> bindServer() async {
    if (server.status == ConnectionStatus.connected) {
      _runs = await repository.getRuns();
    } else {
      _runs = [];
    }
    notifyListeners();
  }

  Future<void> download(Run run) async {
    if (run.status != "SUCCESS" || run.result == null || run.result == "") {
      return server.notification("Không tìm thấy file kết quả");
    }
    final String? directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Save",
      lockParentWindow: true,
    );
    if (directoryPath == null) {
      return;
    }
    final bool success = await repository.downloadResult(
      run: run,
      savePath: directoryPath,
    );
    if (!success) return server.notification("Lưu thất bại!");
    server.notification(
      "Lưu ${p.basename(run.result!)} thành công",
      callBack: () async {
        await OpenFile.open(directoryPath);
      },
      note: "Xem",
    );
  }

  Future<void> stop(Run run) async {
    final bool success = await repository.stop(run);
    if (!success) {
      server.notification("Không thể dừng ${run.robot}");
      return;
    }
    server.notification("Đã gửi yêu cầu dừng ${run.robot}");
  }

  Future<RError?> getError(String id) async {
    return await repository.getError(id);
  }
}
