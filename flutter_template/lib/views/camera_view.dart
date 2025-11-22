import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertemplate/controllers/face_detection_controller.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FaceDetectionScope.of(context);
    final faces = controller.faces;
    final rawEvent = controller.lastRawEvent;
    final prettyEvent =
        rawEvent == null ? null : const JsonEncoder.withIndent('  ').convert(rawEvent);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF302B63),
              Color(0xFF24243E),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white70,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Camera Diagnostics',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSummaryRow(controller),
                const SizedBox(height: 32),
                _buildStateBanner(controller),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: faces.isEmpty
                        ? Center(
                            child: Text(
                              controller.initializing
                                  ? 'Initializing face stream...'
                                  : 'No faces detected right now',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: faces.length,
                            separatorBuilder: (_, __) =>
                                Divider(color: Colors.white.withOpacity(0.08)),
                            itemBuilder: (_, index) {
                              final face = faces[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Colors.blueAccent.withOpacity(0.2),
                                  child: Text(
                                    '#${index + 1}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  'x:${face.x.toStringAsFixed(1)} '
                                  'y:${face.y.toStringAsFixed(1)}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'w:${face.width.toStringAsFixed(1)} '
                                  'h:${face.height.toStringAsFixed(1)} '
                                  'conf:${(face.confidence * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                if (prettyEvent != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Latest payload',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        prettyEvent,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (controller.lastError != null)
                  Text(
                    controller.lastError!,
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(FaceDetectionController controller) {
    return Row(
      children: [
        Expanded(
          child: _CameraStatCard(
            title: 'Faces',
            value: controller.faceCount.toString(),
            icon: Icons.people_alt_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _CameraStatCard(
            title: 'Mode',
            value: controller.viewingMode.name.toUpperCase(),
            icon: Icons.layers_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _CameraStatCard(
            title: 'Distance',
            value: controller.distanceLevel.name.toUpperCase(),
            icon: Icons.center_focus_strong,
          ),
        ),
      ],
    );
  }

  Widget _buildStateBanner(FaceDetectionController controller) {
    String message;
    IconData icon;
    Color color;

    switch (controller.autoPauseState) {
      case AutoPauseState.countdown:
        message =
            'No viewers detected. Auto pause in ${controller.autoPauseRemainingSeconds}s.';
        icon = Icons.timer;
        color = Colors.orangeAccent;
        break;
      case AutoPauseState.paused:
        message = 'Playback paused until someone returns.';
        icon = Icons.pause_circle_filled;
        color = Colors.redAccent;
        break;
      case AutoPauseState.inactive:
      default:
        message = 'Face detection stream is healthy.';
        icon = Icons.check_circle;
        color = Colors.greenAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraStatCard extends StatelessWidget {
  const _CameraStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
