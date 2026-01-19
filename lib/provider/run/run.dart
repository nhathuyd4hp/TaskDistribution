import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:task_distribution/model/run.dart';
import 'package:task_distribution/provider/socket.dart';
import 'package:task_distribution/service/run.dart';

class RunProvider extends ChangeNotifier {
  //
  final RunClient repository;
  final ServerProvider server;
  List<Run> _runs = [];
  bool _isLoading = false;
  String? _errorMessage;
  // Getter
  List<Run> get runs => _runs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // Constructor
  RunProvider({required this.repository, required this.server});
  // bindServer
  Future<void> bindServer() async {
    if (server.status == ConnectionStatus.connecting) {
      _isLoading = true;
      _runs = [];
    }
    if (server.status == ConnectionStatus.connected) {
      _isLoading = false;
      _errorMessage = null;
      _runs = await repository.getRuns();
    }
    if (server.status == ConnectionStatus.disconnected) {
      _isLoading = false;
      _errorMessage = server.errorMessage;
      _runs = [];
    }
    notifyListeners();
  }

  Future<void> download(Run run) async {
    if (run.status != "SUCCESS" || run.result == null) {
      return;
    }
    final String? directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Save",
      lockParentWindow: true,
    );
    if (directoryPath == null) {
      return;
    }
    final bool success = await repository.result(
      run: run,
      savePath: directoryPath,
    );
    if (!success) return server.notification("Lưu thất bại!");
    server.notification(
      "Lưu thành công",
      callBack: () async {
        await OpenFile.open(directoryPath);
      },
    );
  }
}
