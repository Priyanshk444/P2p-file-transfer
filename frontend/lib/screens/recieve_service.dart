import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/io.dart';

class FileReceiver {
  final String senderIP;
  final int senderPort;
  late IOWebSocketChannel channel;
  final Directory publicFolder;

  FileReceiver({required this.senderIP, required this.senderPort})
      : publicFolder = Directory("public");

  Future<void> startReceiving() async {
    // Create "public" folder if it doesn't exist
    if (!publicFolder.existsSync()) {
      publicFolder.createSync();
    }
    
    // Connect to the sender WebSocket
    final uri = Uri.parse('ws://$senderIP:$senderPort');
    channel = IOWebSocketChannel.connect(uri);
    print("Connected to sender at ws://$senderIP:$senderPort");

    IOSink? fileStream;
    String? filePath;

    // Listen to messages from the sender
    channel.stream.listen((message) {
      final data = jsonDecode(message);

      if (data["type"] == "startFile") {
        final fileName = data["fileName"] ?? "downloaded_file";
        filePath = "${publicFolder.path}/$fileName";
        fileStream = File(filePath!).openWrite();
        print("Receiving file: $fileName");

      } else if (data["type"] == "fileChunk") {
        if (fileStream != null) {
          final chunk = base64Decode(data["chunk"]);
          fileStream!.add(chunk);
        }

      } else if (data["type"] == "endOfFile") {
        if (fileStream != null) {
          fileStream!.close();
          print("File received and saved at: $filePath");
        }
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
