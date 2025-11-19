// camera_view.dart
import 'package:flutter/material.dart';
import 'package:fluttertemplate/services/camera_service.dart';
import 'package:fluttertemplate/webos_service_helper/utils.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  String result = '';
  late int cameraSubscribe;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await CameraService.intallModel();
    Map<String, dynamic>? res = await CameraService.getCameraList();
    debugPrint(res.toString());
    Map<String, dynamic>? res1 = await CameraService.setPermission();
    debugPrint(res1.toString());
    Map<String, dynamic>? res2 =
        await CameraService.openCamera(res?['deviceList'][0]['id']);
    debugPrint(res2.toString());
    final handle = res2?['handle'];
    Map<String, dynamic>? res3 = await CameraService.setFormat(handle);
    debugPrint(res3.toString());
    Map<String, dynamic>? res4 = await CameraService.startPreview(handle);
    debugPrint(res4.toString());
    Map<String, dynamic>? res5 =
        await CameraService.setSolutions(res?['deviceList'][0]['id']);
    debugPrint(res5.toString());
    cameraSubscribe =
        CameraService.getEventNotification(res?['deviceList'][0]['id'], (data) {
      debugPrint('Frame data: $data');
      setState(() {
        result = data.toString();
      });
    });
  }

  @override
  void dispose() {
    cancel(cameraSubscribe);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Text(
                'There are $result people watching TV right now.',
                style: const TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5B5D66),
                  minimumSize: const Size(300, 54),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "back",
                  style: TextStyle(
                    fontSize: 27,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'LG Smart UI',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
