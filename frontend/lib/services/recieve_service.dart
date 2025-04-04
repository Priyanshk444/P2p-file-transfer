import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:p2p/providers/download_pregress_provider.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';

class FileReceiver {
  final String senderIP;
  final int senderPort;
  IOWebSocketChannel? _channel;
  File? _file;
  IOSink? _fileSink;
  String receiveFolderPath;
  late Directory _publicFolder;
  int _totalBytesReceived = 0;
  int _expectedTotalBytes = 0;

  FileReceiver(
      {required this.senderIP,
      required this.senderPort,
      required this.receiveFolderPath}) {
    _publicFolder = Directory(receiveFolderPath);
  }

  void start(BuildContext context) {
    final uri = Uri.parse('ws://$senderIP:$senderPort');
    _channel = IOWebSocketChannel.connect(uri);

    if (!_publicFolder.existsSync()) {
      _publicFolder.createSync();
    }

    _channel!.stream.listen(
      (message) => _handleMessage(message, context),
      onDone: _handleDisconnect,
      onError: _handleError,
    );
  }

  void _handleMessage(dynamic message, BuildContext context) {
    try {
      if (message is String) {
        final data = jsonDecode(message);

        if (data['type'] == 'startFile') {
          final fileName = data['fileName'] ?? 'downloaded_file';
          _expectedTotalBytes =
              data['size'] ?? 0; 
          print("size : $_expectedTotalBytes");
          _file = File('${_publicFolder.path}/$fileName');
          _fileSink = _file!.openWrite();
          _totalBytesReceived = 0; 

          Provider.of<DownloadProvider>(context, listen: false)
              .addDownload(fileName, _expectedTotalBytes);

          print('Receiving file: $fileName');
        } else if (data['type'] == 'fileChunk') {
          if (_fileSink != null) {
            final chunk = base64Decode(data['chunk']);
            _fileSink!.add(chunk);

            _totalBytesReceived += chunk.length;
            print(
                'Received chunk of ${chunk.length} bytes. Total received: $_totalBytesReceived bytes.');

            Provider.of<DownloadProvider>(context, listen: false)
                .updateProgress(
                    _file!.path.split('/').last, _totalBytesReceived);

            if (_totalBytesReceived >= _expectedTotalBytes) {
              print('Download completed.');
            }
          }
        } else if (data['type'] == 'endOfFile') {
          _fileSink?.close();
          print('File received and saved at: ${_file?.path}');
          _channel?.sink.close();
        }
      } else {
        print('Unexpected non-string message: ${message.runtimeType}');
      }
    } catch (e) {
      print('Error processing message: $e');
    }
  }

  void _handleDisconnect() {
    print('Disconnected from sender.');
    _fileSink?.close();
  }

  void _handleError(error) {
    print('WebSocket error: $error');
  }
}
