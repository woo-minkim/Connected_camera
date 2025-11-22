import 'package:flutter/material.dart';
import 'package:fluttertemplate/controllers/face_detection_controller.dart';
import 'package:video_player/video_player.dart';

class CustomVideoWidget extends StatefulWidget {
  const CustomVideoWidget({super.key});

  @override
  State<CustomVideoWidget> createState() => _CustomVideoWidgetState();
}

class _CustomVideoWidgetState extends State<CustomVideoWidget> {
  late final VideoPlayerController _player;
  Future<void>? _initFuture;
  FaceDetectionController? _controller;

  @override
  void initState() {
    super.initState();
    _player = VideoPlayerController.networkUrl(
      Uri.parse(
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      ),
    );
    _initFuture = _player.initialize().then((_) {
      if (!mounted) return;
      _player
        ..setLooping(true)
        ..setVolume(0.6)
        ..play();
      final faceController =
          FaceDetectionScope.of(context, listen: false);
      faceController.setPlaybackActive(true);
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = FaceDetectionScope.of(context);
    if (_controller == scope) return;
    _controller?.removeListener(_handleFaceUpdates);
    _controller = scope;
    _controller?.addListener(_handleFaceUpdates);
  }

  void _handleFaceUpdates() {
    if (!mounted) return;
    final state = _controller?.autoPauseState;
    if (state == AutoPauseState.paused && _player.value.isPlaying) {
      _player.pause();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleFaceUpdates);
    if (_player.value.isInitialized) {
      FaceDetectionScope.of(context, listen: false)
          .setPlaybackActive(false);
    }
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final faceController = FaceDetectionScope.of(context);
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (_, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            width: 320,
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Container(
          width: 420,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _player.value.aspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: VideoPlayer(_player),
                ),
              ),
              _buildOverlay(faceController),
              Positioned(
                bottom: 12,
                right: 12,
                child: IconButton(
                  onPressed: () {
                    if (_player.value.isPlaying) {
                      _player.pause();
                      faceController.setPlaybackActive(false);
                    } else {
                      _player.play();
                      faceController.setPlaybackActive(true);
                    }
                    setState(() {});
                  },
                  icon: Icon(
                    _player.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverlay(FaceDetectionController controller) {
    switch (controller.autoPauseState) {
      case AutoPauseState.countdown:
        return _OverlayMessage(
          icon: Icons.timer,
          message:
              'No viewers detected.\nPausing in ${controller.autoPauseRemainingSeconds}s',
        );
      case AutoPauseState.paused:
        return _OverlayMessage(
          icon: Icons.pause,
          message: 'Playback paused.\nTap resume when you are back.',
          actionLabel: 'Resume',
          onAction: () {
            if (controller.faceCount == 0) return;
            controller.acknowledgeResume();
            controller.setPlaybackActive(true);
            _player.play();
            setState(() {});
          },
        );
      case AutoPauseState.inactive:
      default:
        return const SizedBox.shrink();
    }
  }
}

class _OverlayMessage extends StatelessWidget {
  const _OverlayMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
