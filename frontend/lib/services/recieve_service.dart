// import 'dart:convert';
// import 'dart:io';
// import 'package:web_socket_channel/io.dart';

// class FileReceiver {
//   final String senderIP;
//   final int senderPort;
//   late IOWebSocketChannel channel;
//   final Directory publicFolder;
//   final Function(double progress)? onProgressUpdate;

//   FileReceiver({
//     required this.senderIP,
//     required this.senderPort,
//     this.onProgressUpdate,
//   }) : publicFolder = Directory("public");

//   Future<void> startReceiving() async {
//     try {
//       // Create the "public" folder if it doesn't exist
//       if (!publicFolder.existsSync()) {
//         publicFolder.createSync();
//       }

//       // Connect to the sender WebSocket
//       final uri = Uri.parse('ws://$senderIP:$senderPort');
//       channel = IOWebSocketChannel.connect(uri);
//       print("Connected to sender at ws://$senderIP:$senderPort");

//       IOSink? fileStream;
//       String? filePath;
//       int totalFileSize = 0;
//       int receivedBytes = 0;

//       channel.stream.listen(
//         (message) {
//           print("Received message: $message"); // Debug message content
//           try {
//             final data = jsonDecode(message);

//             if (data["type"] == "startFile") {
//               final fileName = data["fileName"] ?? "downloaded_file";
//               totalFileSize = data["totalSize"] ?? 0;
//               filePath = "${publicFolder.path}/$fileName";
//               fileStream = File(filePath!).openWrite();
//               receivedBytes = 0; // Reset byte count
//               print(
//                   "Starting to receive file: $fileName (Total size: $totalFileSize bytes)");
//             } else if (data["type"] == "fileChunk") {
//               if (fileStream != null) {
//                 final chunk = base64Decode(data["chunk"]);
//                 fileStream!.add(chunk);
//                 receivedBytes += chunk.length;

//                 // Calculate download progress and update UI
//                 if (totalFileSize > 0) {
//                   double progress = (receivedBytes / totalFileSize) * 100;
//                   onProgressUpdate?.call(progress);
//                   print("Download progress: ${progress.toStringAsFixed(2)}%");
//                 }
//               } else {
//                 print("Error: File stream is null when receiving fileChunk.");
//               }
//             } else if (data["type"] == "endOfFile") {
//               if (fileStream != null) {
//                 fileStream!.close();
//                 print("File download complete! Saved at: $filePath");
//                 onProgressUpdate?.call(100); // Notify 100% completion
//               } else {
//                 print("Error: File stream is null at endOfFile.");
//               }
//             } else {
//               print("Unknown message type: ${data["type"]}");
//             }
//           } catch (e) {
//             print("Error processing received message: $e");
//           }
//         },
//         onDone: () {
//           print("Connection to sender closed.");
//           fileStream?.close();
//         },
//         onError: (error) {
//           print("WebSocket error: $error");
//           fileStream?.close();
//         },
//       );
//     } catch (e) {
//       print("Failed to establish WebSocket connection: $e");
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:web_socket_channel/io.dart';

class FileReceiver {
  final String senderIP;
  late IOWebSocketChannel channel;
  final Directory publicFolder;

  FileReceiver({required this.senderIP}) : publicFolder = Directory("public");

  Future<void> startReceiving(dynamic availablePort) async {
    // Create "public" folder if it doesn't exist
    if (!publicFolder.existsSync()) {
      publicFolder.createSync();
    }

    // Connect to the sender WebSocket
    final uri = Uri.parse('ws://$senderIP:$availablePort');
    channel = IOWebSocketChannel.connect(uri);
    print("Connected to sender at ws://$senderIP:$availablePort");

    IOSink? fileStream;
    String? filePath;

    // Listen to messages from the sender (both binary and text)
    channel.stream.listen((message) {
      try {
        if (message is String) {
          // Handle JSON-encoded text messages
          final data = jsonDecode(message);

          if (data["type"] == "startFile") {
            final fileName = data["fileName"] ?? "downloaded_file";
            filePath = "${publicFolder.path}/$fileName";
            fileStream = File(filePath!).openWrite();
            print("Receiving file: $fileName");
          } else if (data["type"] == "endOfFile") {
            if (fileStream != null) {
              fileStream!.close();
              print("File received and saved at: $filePath");
            }
          } else {
            print("Unexpected message type: ${data["type"]}");
          }
        } else if (message is Uint8List) {
          // Handle binary data (file chunks)
          fileStream?.add(message);
        } else {
          print("Received unknown message type.");
        }
      } catch (e) {
        print("Error: $e");
      }
    }, onDone: () {
      print("Disconnected from sender.");
      fileStream?.close();
    }, onError: (error) {
      print("Error: $error");
      fileStream?.close();
    });
  }
}

