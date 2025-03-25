import 'dart:async';
import 'dart:io';

import 'package:p2p/screens/recieve_service.dart';
import 'package:p2p/screens/sender_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

class SocketService with ChangeNotifier {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? socket;
  List<Map<String, dynamic>> groupMessage = [];
  Map<String, List<Map<String, dynamic>>> directMessage = {};
  List<dynamic> users = [];
  final fileReceiver = FileReceiver(senderIP: "192.168.50.179");

  dynamic availablePort;
  SocketService._internal();

  void connect() {
    if (socket != null && socket!.connected) {
      // Prevent duplicate connections
      print('Socket already connected: ${socket!.id}');
      return;
    }

    socket ??= IO.io(
      'http://192.168.50.179:9000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    socket!.onConnect((_) {
      print('Connected: ${socket!.id}');
      
    });

    // Register listeners only once to avoid duplicates
    socket!.off('message');
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
    socket!.on('free-port', (data) {
      availablePort = data['availablePort'];
    });
    socket!.on("fileRequest", (data) async {
      final freePort = await getFreePort();
      final fileSender = FileSender(
          availablePort: freePort,
          filePath: data['file'],
          senderIP: '192.168.137.10');
      socket!.emit("portInfo",
          {"availablePort": freePort, "userSocketId": data['userSocketId']});
      fileSender.startSendingFile();
    });
    socket!.onDisconnect((_) => print('Disconnected from server'));
  }

  bool isConnected() => socket != null && socket!.connected;

  void registerUser(String username, String shareFolderPath, String serverIP) {
    socket!.emit('register', {
        'username': username,
        'fileList': getFolderContents(shareFolderPath),
        'ip': serverIP,
      });
  }
  
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

  Future<int> getFreePort() async {
    final socket = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    final port = socket.port; // Get the dynamically assigned free port
    await socket.close(); // Close the socket to free up the port
    return port;
  }

  void downloadFile(String fileId) async {
    if (socket != null && socket!.connected) {
      socket!.emit('requestFile', {'fileId': fileId});

      if (availablePort == null) {
        print("Waiting for available port...");
        Timer.periodic(Duration(milliseconds: 100), (timer) async {
          if (availablePort != null) {
            print("Port found: $availablePort. Starting file download.");
            timer.cancel();
            // Start receiving the file
            await fileReceiver.startReceiving(availablePort);
            availablePort = null;
          } else {
            print("Port not found yet. Retrying...");
          }
        });
      } else {
        // Start receiving if port is already set (unlikely but handled)
        await fileReceiver.startReceiving(availablePort);
        availablePort = null;
      }
    }
  }

  // void downloadFile(String fileId,
  //     {required Function(double) onProgressUpdate}) async {
  //   // File download logic here (socket communication)
  //   int bytesReceived = 0;
  //   int totalFileSize = 1000000; // Example file size (adjust as needed)

  //   // Simulate receiving chunks of data with progress updates
  //   while (bytesReceived < totalFileSize) {
  //     // Download logic receiving chunks here
  //     await Future.delayed(
  //         Duration(milliseconds: 100)); // Simulate chunk download
  //     bytesReceived += 5000; // Increment received bytes

  //     // Calculate download progress
  //     double progress = (bytesReceived / totalFileSize) * 100;
  //     onProgressUpdate(progress); // Callback to update UI
  //   }
  // }

  void disconnect() {
    socket?.disconnect();
  }

  factory SocketService() {
    return _instance;
  }

  List<Map<String, dynamic>> getFolderContents(String folderPath) {
    List<Map<String, dynamic>> results = [];

    try {
      Directory folder = Directory(folderPath);
      List<FileSystemEntity> entities = folder.listSync();

      for (var entity in entities) {
        FileStat stats = entity.statSync();
        String type =
            stats.type == FileSystemEntityType.directory ? "folder" : "file";

        int size = 0;
        if (type == "file") {
          size = stats.size; // File size in bytes
        } else if (type == "folder") {
          // Calculate folder size by recursively summing file sizes
          size = _calculateFolderSize(entity.path);
        }

        results.add({
          "name": entity.uri.pathSegments.last,
          "path": entity.path,
          "type": type,
          "size": size,
        });

        if (type == "folder") {
          // Add folder contents recursively
          results.addAll(getFolderContents(entity.path));
        }
      }
    } catch (e) {
      print("Error reading folder: $e");
    }

    return results;
  }

// Helper function to recursively calculate the folder size
  int _calculateFolderSize(String folderPath) {
    int totalSize = 0;
    try {
      Directory folder = Directory(folderPath);
      List<FileSystemEntity> entities = folder.listSync();

      for (var entity in entities) {
        FileStat stats = entity.statSync();
        if (stats.type == FileSystemEntityType.file) {
          totalSize += stats.size;
        } else if (stats.type == FileSystemEntityType.directory) {
          totalSize +=
              _calculateFolderSize(entity.path); // Recursively add folder sizes
        }
      }
    } catch (e) {
      print("Error calculating folder size: $e");
    }

    return totalSize;
  }

  // List<Map<String, String>> getFolderContents(String folderPath) {
  //   List<Map<String, String>> results = [];

  //   try {
  //     Directory folder = Directory(folderPath);
  //     List<FileSystemEntity> entities = folder.listSync();

  //     for (var entity in entities) {
  //       FileStat stats = entity.statSync();
  //       String type =
  //           stats.type == FileSystemEntityType.directory ? "folder" : "file";

  //       results.add({
  //         "name": entity.uri.pathSegments.last,
  //         "path": entity.path,
  //         "type": type,
  //       });

  //       if (type == "folder") {
  //         results.addAll(getFolderContents(entity.path));
  //       }
  //     }
  //   } catch (e) {
  //     print("Error reading folder: $e");
  //   }
  //   // print(results);
  //   return results;
  // }
}
