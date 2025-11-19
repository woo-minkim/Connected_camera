import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoWidget extends StatefulWidget {
  const CustomVideoWidget({super.key});

  @override
  State<CustomVideoWidget> createState() => _CustomVideoWidgetState();
}

class _CustomVideoWidgetState extends State<CustomVideoWidget> {
  late VideoPlayerController controller;

  Future<void> initVideo() async {
    controller = VideoPlayerController.networkUrl(Uri.parse(
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'));

    await controller.initialize();
    controller.play();
    controller.setVolume(50);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initVideo(),
      builder: (_, snapshot) {
        print(snapshot.connectionState);
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            width: 300,
            height: 200,
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller)),
          );
        } else {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
