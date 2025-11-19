import 'package:flutter/material.dart';
import 'package:fluttertemplate/services/notification_service.dart';

class MainView extends StatefulWidget {
  const MainView({super.key, required this.title});
  final String title;

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int itemCount = 0;
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await NotificationService().getNotifications();
      // 상태 관리 관련
      setState(() {
        data = notifications;
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header로 분리
            Text(
              widget.title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 60,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$itemCount Items',
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // routing 관련
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5B5D66),
                    minimumSize: const Size(300, 54),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/sub');
                  },
                  child: const Text(
                    "next page",
                    style: TextStyle(
                      fontSize: 27,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'LG Smart UI',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5B5D66),
                    minimumSize: const Size(300, 54),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/camera');
                  },
                  child: const Text(
                    'camera page',
                    style: TextStyle(
                      fontSize: 27,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'LG Smart UI',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Alert 관련
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5B5D66),
                    minimumSize: const Size(300, 54),
                  ),
                  onPressed: () {
                    print('test');
                    showDeleteAllDialog(context, () async {
                      // 상태 관리 관련
                      setState(() {
                        data.clear();
                      });
                      var res = await NotificationService()
                          .createNotification('All notifications deleted');
                      debugPrint('All notifications deleted $res');
                    });
                  },
                  child: const Text(
                    'Delete all',
                    style: TextStyle(
                      fontSize: 27,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'LG Smart UI',
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // 상태 관리 관련
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5B5D66),
                    minimumSize: const Size(300, 54),
                  ),
                  onPressed: () {
                    setState(() {
                      data.add({
                        "id": 4,
                        "date": "2023년 3월 1일",
                        "title": "새로운 알림 1",
                        "message": "추가된 알림 내용 1입니다.",
                      });
                    });
                    debugPrint('Notification added $data');
                  },
                  child: const Text(
                    "Add Notification",
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
            const Divider(
              color: Colors.white,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: const Icon(Icons.alarm_on),
                    title: Text(data[index]['title']),
                    subtitle: Text(data[index]['message']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showDeleteAllDialog(
    BuildContext context, VoidCallback onYes) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('알림'),
        content: const Text('전체 삭제하시겠습니까?'),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop();
              onYes();
            },
          ),
        ],
      );
    },
  );
}
