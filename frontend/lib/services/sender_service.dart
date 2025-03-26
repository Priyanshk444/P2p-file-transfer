import 'dart:convert';
import 'dart:io';

class FileSender {
  final String filePath;
  final String senderIP;
  final int availablePort;

  FileSender({required this.filePath, required this.senderIP, required this.availablePort});

  Future<void> startSendingFile() async {
    final file = File(filePath);

    if (!file.existsSync()) {
      print("File does not exist: $filePath");
      return;
    }

    final fileName = file.uri.pathSegments.last;
    final server = await HttpServer.bind(senderIP, availablePort);
    print("WebSocket server started at ws://$senderIP:$availablePort");

    server.transform(WebSocketTransformer()).listen((WebSocket ws) async {
      print("Receiver connected.");
      
      // Send file metadata first
      ws.add(jsonEncode({"type": "startFile", "fileName": fileName}));

      // Send file in chunks (64 KB chunks)
      final stream = file.openRead();
      await for (final chunk in stream) {
        if (ws.readyState == WebSocket.open) {
          final base64Chunk = base64Encode(chunk);
          ws.add(jsonEncode({"type": "fileChunk", "chunk": base64Chunk}));
        } else {
          print("WebSocket is not open. Stopping file transfer.");
          break;
        }
      }

      // Send end of file message
      ws.add(jsonEncode({"type": "endOfFile"}));
      print("File transfer complete.");

      // Close WebSocket and stop listening to new connections
      await ws.close();
      await server.close(force: true);
      print("WebSocket server closed, releasing port.");
    }, onError: (error) {
      print("WebSocket server error: $error");
      server.close();
    });
  }
}
