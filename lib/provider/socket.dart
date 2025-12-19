import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';
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
  // Latest message
  String? _latestMessage;
  String? get latestMessage => _latestMessage;
  void clearLatestMessage() {
    _latestMessage = null;
  }

  void clearErrorMessage() {
    _errorMessage = null;
  }

  void setLatestMessage(String message) {
    _latestMessage = message;
    notifyListeners();
  }

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
      _errorMessage = null;
      notifyListeners();
      channel.stream.listen(
        (message) {
          try {
            if (message is String) {
              _latestMessage = message;
            }
            if (message is List<int>) {
              _latestMessage = utf8.decode(message);
            }
          } catch (e) {
            _latestMessage = message.toString();
          } finally {
            notifyListeners();
          }
        },
        onDone: () {
          _reconnect(url);
        },
        onError: (error) {
          _errorMessage = error.toString();
          _reconnect(url);
        },
        cancelOnError: true,
      );
    } catch (error) {
      _errorMessage = error.toString();
      _reconnect(url);
    }
  }

  Future<void> _reconnect(String url) async {
    _currentStatus = ConnectionStatus.disconnected;
    notifyListeners();
    await Future.delayed(Duration(seconds: 15));
    await _connect(url);
  }

  // Bắn thông báo
  void notification(String message) {
    _latestMessage = message;
    notifyListeners();
  }

  void warning(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
