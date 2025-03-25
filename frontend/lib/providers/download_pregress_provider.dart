import 'package:flutter/material.dart';

class DownloadState extends ChangeNotifier {
  double _progress = 0.0; // Tracks the progress (0.0 to 100.0)

  double get progress => _progress;

  void updateProgress(double newProgress) {
    _progress = newProgress;
    notifyListeners();
  }

  void resetProgress() {
    _progress = 0.0;
    notifyListeners();
  }
}
