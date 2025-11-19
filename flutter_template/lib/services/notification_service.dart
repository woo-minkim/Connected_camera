import 'package:fluttertemplate/webos_service_helper/utils.dart';

class NotificationService {
  Future<List<Map<String, dynamic>>> getNotifications() async {
    return [
      {
        "id": 1,
        "date": "2023년 3월 1일",
        "title": "새로운 알림 1",
        "message": "알림 내용 1입니다.",
      },
      {
        "id": 2,
        "date": "2023년 3월 2일",
        "title": "새로운 알림 2",
        "message": "알림 내용 2입니다.",
      },
      {
        "id": 3,
        "date": "2023년 3월 3일",
        "title": "새로운 알림 3",
        "message": "알림 내용 3입니다.",
      },
    ];
  }

  Future<Map<String, dynamic>?> createNotification(String msg) async {
    // 알림 생성
    // luna-send -n 1 -f -a com.webos.app.test luna://com.webos.notification/createToast '{"message":"hello world"}'
    // if (kIsWeb) {
    //   return {"returnValue": true};
    // }

    return await callOneReply(
      uri: 'luna://com.webos.notification',
      method: 'createToast',
      payload: {
        "message": msg,
      },
    );
  }
}
