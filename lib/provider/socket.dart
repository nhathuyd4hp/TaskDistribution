import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum ConnectionStatus { connecting, connected, disconnected }

class ServerProvider extends ChangeNotifier {
  // Tình trạng kết nối
  ConnectionStatus _currentStatus = ConnectionStatus.connecting;
  ConnectionStatus get status => _currentStatus;
  // errorMessage
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  // Client
  late WebSocketChannel channel;
  // Khởi tạo
  ServerProvider(String url) {
    _connect(url);
  }

  Future<void> _connect(String url) async {
    _currentStatus = ConnectionStatus.connecting;
    notifyListeners(); // Thông báo đang kết nối
    // ---- //
    final wsUrl = Uri.parse(url);
    channel = WebSocketChannel.connect(wsUrl);
    try {
      await channel.ready;
      _currentStatus = ConnectionStatus.connected;
      notifyListeners();
      channel.stream.listen(
        (message) {},
        onDone: () {
          _reconnect(url);
        },
        onError: (error) {
          _reconnect(url);
        },
        cancelOnError: true,
      );
    } catch (err) {
      _reconnect(url);
    }
  }

  Future<void> _reconnect(String url) async {
    _currentStatus = ConnectionStatus.disconnected;
    _errorMessage = "Không thể kết nối đến server";
    notifyListeners(); // Thông báo đã mất kết nối
    await Future.delayed(Duration(seconds: 5)); // Kết nối lại sau 5s
    _connect(url);
  }
}
