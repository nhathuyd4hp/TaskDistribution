import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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
    if (run.status != "SUCCESS") {
      server.warning(run.result ?? "Run failed");
      return;
    }
    if (run.result == null) {
      server.warning("No result found");
      return;
    }
    final String? directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Save file",
      lockParentWindow: true,
    );
    if (directoryPath == null) {
      return;
    }
    final (success, message) = await repository.getResult(
      run: run,
      savePath: directoryPath,
    );
    if (success) {
      server.notification(message);
    } else {
      server.warning(message);
    }
  }
}
