// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class SocketService with ChangeNotifier {
//   Socket? socket;
//   final String serverIp = "192.168.137.205";
//   final int port = 12345;
//   List<Map<String, dynamic>> messages = [];
//   final String receivedFilesPath =
//       "D:/P2P/P2p-file-transfer/frontend/received_files";

//   Future<void> connect() async {
//     try {
//       socket = await Socket.connect(serverIp, port);
//       print("Connected to Java backend");

//       _ensureDirectoryExists(receivedFilesPath);

//       socket!.listen(
//         (List<int> data) async {
//           String message = utf8.decode(data, allowMalformed: true);
//           print("Received: $message");

//           if (message.startsWith("FILE")) {
//             // await receiveFile();
//           } else {
//             messages.add({"sender": "Peer", "message": message});
//           }
//           notifyListeners();
//         },
//         onError: (error) {
//           print("Error: $error");
//           disconnect();
//         },
//         onDone: () {
//           print("Connection closed by server");
//           disconnect();
//         },
//       );
//       notifyListeners();
//     } catch (e) {
//       print("Connection failed: $e");
//     }
//   }

//   Future<void> sendRegistrationData({
//     required String ipAddress,
//     required int port,
//     required String hostName,
//     required String status,
//     required String sendFileLocation,
//     required String recievedFileLocation,
//     required String lastActive,
//   }) async {
//     String endpointUrl = "http://192.168.137.205:8080/peer/add";
//     Map<String, dynamic> registrationData = {
//       "ipAddress": ipAddress,
//       "port": port,
//       "hostName": hostName,
//       "status": status,
//       "sendFileLocation": sendFileLocation,
//       "recievedFileLocation": recievedFileLocation,
//       "lastActive": lastActive,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(endpointUrl),
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode(registrationData),
//       );

//       if (response.statusCode == 200) {
//         print("✅ Registration data sent successfully!");
//       } else {
//         print(
//             "❌ Failed to send registration data. Status code: ${response.statusCode}");
//         print("Response body: ${response.body}");
//       }
//     } catch (e) {
//       print("❌ Error sending registration data: $e");
//     }
//   }

//   void sendMessage(String message) {
//     if (socket == null) {
//       print("Socket is not connected. Cannot send data.");
//       return;
//     }

//     Map<String, dynamic> messageData = {"type": "message", "content": message};

//     String jsonData = jsonEncode(messageData);
//     socket!.write(jsonData);
//     print("Sent message: $jsonData");
//   }

//   // Future<void> sendFile(String filePath) async {
//   //   if (socket == null) {
//   //     print("Socket is not connected.");
//   //     return;
//   //   }

//   //   File file = File(filePath);
//   //   if (!await file.exists()) {
//   //     print("File not found: $filePath");
//   //     return;
//   //   }

//   //   String fileName = file.uri.pathSegments.last;
//   //   int fileSize = await file.length();

//   //   // Send FILE marker first
//   //   String metadata = "FILE\n$fileName\n$fileSize\n";
//   //   socket!.add(utf8.encode(metadata));
//   //   await socket!.flush(); // Ensure metadata is sent before file data

//   //   // Send file data in chunks
//   //   Stream<List<int>> fileStream = file.openRead();
//   //   await for (List<int> chunk in fileStream) {
//   //     socket!.add(chunk);
//   //   }

//   //   await socket!.flush(); // Ensure all data is written

//   //   // Send EOF marker to indicate file transfer is complete
//   //   socket!.add(utf8.encode("\nEOF\n"));
//   //   await socket!.flush();

//   //   print("File sent: $fileName");
//   // }

//   // Future<void> receiveFile() async {
//   //   if (socket == null) return;

//   //   try {
//   //     // Read file name
//   //     String fileName = await _readLine();
//   //     // Read file size
//   //     int fileSize = int.parse(await _readLine());

//   //     // Create the file
//   //     File file = File("$receivedFilesPath/$fileName");
//   //     _ensureDirectoryExists(file.parent.path);
//   //     IOSink fileSink = file.openWrite();

//   //     int receivedBytes = 0;
//   //     List<int> buffer = [];

//   //     await for (List<int> chunk in socket!.asBroadcastStream()) {
//   //       buffer.addAll(chunk);
//   //       receivedBytes += chunk.length;
//   //       if (receivedBytes >= fileSize) break;
//   //     }

//   //     fileSink.add(buffer);
//   //     await fileSink.close();
//   //     // print("File received: ${file.path}");
//   //   } catch (e) {
//   //     print("Error receiving file: $e");
//   //   }
//   // }

//   // Future<String> _readLine() async {
//   //   List<int> data = [];
//   //   await for (var chunk in socket!.asBroadcastStream()) {
//   //     data.addAll(chunk);
//   //     if (utf8.decode(data).contains("\n")) break;
//   //   }
//   //   return utf8.decode(data).trim();
//   // }

//   void _ensureDirectoryExists(String path) {
//     Directory dir = Directory(path);
//     if (!dir.existsSync()) {
//       dir.createSync(recursive: true);
//     }
//   }

//   void disconnect() {
//     socket?.close();
//     socket = null;
//     notifyListeners();
//   }
// }



import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

class SocketService with ChangeNotifier {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? socket;
  List<Map<String, dynamic>> messages = [];
  List<dynamic> users = [];

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
      messages.add(data);
      notifyListeners();
    });

    socket!.on('dmessage', (data) {
      print('Received dmessage: $data');
      messages.add(data);
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
      socket!.emit('groupMessage', {'msg' :msg, 'user': 'Aksh'});
    }
  }

  void sendDirectMessage(String msg) {
    if (socket != null && socket!.connected) {
      socket!.emit('directMessage', {'msg' :msg, 'user': 'Aksh'});
    }
  }

  void donloadFile(String path) {
    if (socket != null && socket!.connected) {
      socket!.emit('downloadFile', {'path': path});
    }
  }
  void disconnect() {
    socket?.disconnect();
  }

  factory SocketService() {
    return _instance;
  }
}

