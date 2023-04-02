import 'package:flutter/material.dart';
import 'package:invidious/controllers/miniPayerController.dart';
import 'package:invidious/views/components/compactVideo.dart';
import 'package:invidious/views/videoPlayer/miniPlayerControls.dart';

class VideoQueue extends StatelessWidget {
  final MiniPlayerController controller;

  const VideoQueue({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.videos.length > 0
        ? Column(
            children: [
              ...controller.videos.map((e) {
                bool isPlaying = controller.videos[controller.currentIndex].videoId == e.videoId;
                return CompactVideo(
                  onTap: () => controller.switchToVideo(e),
                  video: e,
                  highlighted: isPlaying,
                  trailing: isPlaying ? [] : [IconButton(onPressed: () => controller.removeVideoFromQueue(e), icon: const Icon(Icons.clear))],
                );
              }).toList()
            ],
          )
        : const Text('empty queue, should never be displayed');
  }
}