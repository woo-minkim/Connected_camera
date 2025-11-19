import 'package:fluttertemplate/webos_service_helper/utils.dart';

class CameraService {
  // Camera service implementation
  static Future<Map<String, dynamic>?> intallModel() async {
    return await callOneReply(
      uri: 'luna://com.webos.service.aiinferencemanager',
      method: 'installModel',
      payload: {"id": "FACE"},
    );
  }

  static Future<Map<String, dynamic>?> getCameraList() async {
    return await callOneReply(
      uri: 'luna://com.webos.service.camera2',
      method: 'getCameraList',
      payload: {},
    );
  }

  static Future<Map<String, dynamic>?> setPermission() async {
    return await callOneReply(
      uri: 'luna://com.webos.service.camera2',
      method: 'setPermission',
      payload: {"appId": "com.webos.app.camera"},
    );
  }

  static Future<Map<String, dynamic>?> openCamera(String cameraId) async {
    return await callOneReply(
      uri: 'luna://com.webos.service.camera2',
      method: 'open',
      payload: {
        "appId": "com.webos.app.camera",
        "id": cameraId,
        "mode": "primary"
      },
    );
  }

  static Future<Map<String, dynamic>?> setFormat(int handle) async {
    return await callOneReply(
      uri: 'luna://com.webos.service.camera2',
      method: 'setFormat',
      payload: {
        "handle": handle,
        "params": {"format": "JPEG", "fps": 30, "height": 720, "width": 1280}
      },
    );
  }

  static Future<Map<String, dynamic>?> startPreview(int handle) async {
    return await callOneReply(
      uri: 'luna://com.webos.service.camera2',
      method: 'startPreview',
      payload: {
        "handle": handle,
        "params": {"source": "0", "type": "sharedmemory"}
      },
    );
  }

  static Future<Map<String, dynamic>?> setSolutions(String cameraId) async {
    return await callOneReply(
      uri: 'luna://com.webos.service.camera2',
      method: 'setSolutions',
      payload: {
        "id": cameraId,
        "solutions": [
          {
            "name": "FaceDetection",
            "params": {"enable": true}
          }
        ]
      },
    );
  }

  static int getEventNotification(String cameraId, Function onComplete) {
    return subscribe(
        uri: 'luna://com.webos.service.camera2',
        method: 'getEventNotification',
        payload: {
          "subscribe": true,
          "category": "solution",
          "id": cameraId,
          "key": ["FaceDetection"]
        },
        onComplete: (data) {
          onComplete(data);
        });
  }
}