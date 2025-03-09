import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final Dio _dio = Dio();
  CancelToken _cancelToken = CancelToken();
  double _progress = 0.0;
  bool _isPaused = false;
  String downloadUrl = "https://sample-videos.com/img/Sample-jpg-image-500kb.jpg"; // Replace with actual URL
  String savePath = "Downloads"; // Change for real path

  Future<void> startDownload() async {
    try {
      await _dio.download(
        downloadUrl,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        print("Download canceled");
      } else {
        print("Download error: $e");
      }
    }
  }

  void pauseDownload() {
    if (!_isPaused) {
      _cancelToken.cancel();
      setState(() {
        _isPaused = true;
        _cancelToken = CancelToken(); // Reset cancel token for resuming
      });
    }
  }

  void resumeDownload() {
    if (_isPaused) {
      setState(() {
        _isPaused = false;
      });
      startDownload(); // Restart the download
    }
  }

  void cancelDownload() {
    _cancelToken.cancel();
    setState(() {
      _progress = 0.0;
      _isPaused = false;
      _cancelToken = CancelToken(); // Reset for new download
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Download Manager")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(value: _progress, minHeight: 8),
            SizedBox(height: 10),
            Text("${(_progress * 100).toStringAsFixed(1)}%"),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: startDownload,
                  child: Text("Start"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isPaused ? resumeDownload : pauseDownload,
                  child: Text(_isPaused ? "Resume" : "Pause"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: cancelDownload,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Cancel"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
