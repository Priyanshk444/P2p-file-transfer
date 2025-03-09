import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

class SocketService with ChangeNotifier {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? socket;
  List<Map<String, dynamic>> messages = [];

  SocketService._internal();

  void connect() {
    if (socket != null && socket!.connected) {
      return;
    }

    socket ??= IO.io(
      'http://192.168.67.93:9000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .build(), 
    );

    socket!.onConnect((_) {
      print('Connected: ${socket!.id}');
      socket!.emit('register', {
        'username': 'Mahil',
        'fileList': [],
        'ip': '192.168.45.45',
      });
    });

    // Ensure old listeners are removed before adding new ones
    socket!.off('message');
    socket!.on('message', (data) {
      print('Received message: $data');
      messages.add(data);
      notifyListeners();
    });

    socket!.onDisconnect((_) => print('Disconnected from server'));
  }

  void sendMessage(String msg) {
    if (socket != null && socket!.connected) {
      socket!.emit('groupMessage', msg);
    }
  }

  void disconnect() {
    socket!.disconnect();
  }

  factory SocketService() {
    return _instance;
  }
}
