import 'package:flutter/material.dart';
import 'package:p2p/providers/download_pregress_provider.dart';
import 'package:provider/provider.dart';

class DownloadProgressWidget extends StatelessWidget {
  const DownloadProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<DownloadState>(context).progress;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey[300],
            color: Colors.teal.withAlpha((0.6 * 255).toInt()),
            minHeight: 10,
          ),
          SizedBox(height: 8),
          Text('${progress.toStringAsFixed(2)}% downloaded'),
        ],
      ),
    );
  }
}
