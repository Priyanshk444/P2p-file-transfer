import 'package:p2p/screens/recieve_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

class SocketService with ChangeNotifier {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? socket;
  List<Map<String, dynamic>> groupMessage = [];
  Map<String, List<Map<String,dynamic>>> directMessage = {};
  List<dynamic> users = [];
  final fileReceiver =
      FileReceiver(senderIP: "192.168.66.111", senderPort: 7000);

  SocketService._internal();

  void connect() {
    if (socket != null && socket!.connected) {
      // Prevent duplicate connections
      print('Socket already connected: ${socket!.id}');
      return;
    }

    socket ??= IO.io(
      'http://192.168.66.111:9000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    socket!.onConnect((_) {
      print('Connected: ${socket!.id}');
      socket!.emit('register', {
        'username': 'Aksh',
        'fileList': [
          {
            'name': 'file1',
            'path': '/path/to/file1',
            'type': 'file',
          }
        ],
        'ip': '192.168.45.45',
      });
    });
    
    // Register listeners only once to avoid duplicates
    // socket!.off('message');
    socket!.on('gmessage', (data) {
      print('Received gmessage: $data');
      groupMessage.add(data);
      notifyListeners();
    });

    socket!.on('dmessage', (data) {
      print('Received dmessage: $data');
      groupMessage.add(data);
      notifyListeners();
    });

    socket!.on('user_joined', (data) {
      print('User joined: $data');
      users.add(data['newUser']);
      // add user to list
      notifyListeners();
    });
    socket!.onDisconnect((_) => print('Disconnected from server'));
  }

  bool isConnected() => socket != null && socket!.connected;

  void sendGroupMessage(String msg) {
    if (socket != null && socket!.connected) {
      socket!.emit('groupMessage', {'msg': msg, 'user': 'Aksh'});
    }
  }

  void sendDirectMessage(String msg) {
    if (socket != null && socket!.connected) {
      socket!.emit('directMessage', {'msg': msg, 'user': 'Aksh'});
    }
  }

  void downloadFile(String fileId) async {
    if (socket != null && socket!.connected) {
      socket!.emit('requestFile', {'fileId': fileId});
      await fileReceiver.startReceiving();
    }
  }

  void disconnect() {
    socket?.disconnect();
  }

  factory SocketService() {
    return _instance;
  }
}
