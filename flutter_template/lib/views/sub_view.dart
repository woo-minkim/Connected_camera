import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertemplate/services/mem_service.dart';
import 'package:fluttertemplate/webos_service_helper/utils.dart';
import 'package:fluttertemplate/widgets/video_widget.dart';

class SubView extends StatefulWidget {
  const SubView({super.key});

  @override
  State<SubView> createState() => _SubViewState();
}

class _SubViewState extends State<SubView> {
  String result = '';
  late int memSubscribe;
  late int statSubscribe;

  @override
  void initState() {
    memSubscribe = MemService.subscribeUnitList(
      onComplete: (data) {
        // print('UnitList updated: ${data['unitList']}');
        List<dynamic> procList = data['procList'] ?? [];
        print(procList[0]);
        print(procList[1]);
        print(procList[2]);
        print(procList[3]);
        setState(() {
          result = data['procList'].toString();
        });
      },
      onError: (error) {
        print('UnitList error: $error');
      },
    );
    // statSubscribe = MemService.subscribeProcStat(
    //   onComplete: (data) {
    //     print('ProcStat updated: $data');
    //   },
    //   onError: (error) {
    //     print('ProcStat error: $error');
    //   },
    // );
    super.initState();
  }

  @override
  void dispose() {
    cancel(memSubscribe);
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
              const Text(
                'Hello, Sub View!',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                ),
              ),
              const CustomVideoWidget(),
              Text(
                result,
                style: const TextStyle(
                  fontSize: 36,
                  color: Colors.blue,
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
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5B5D66),
                      minimumSize: const Size(300, 54),
                    ),
                    onPressed: () {
                      callOneReply(
                          uri: 'luna://com.webos.applicationManager',
                          method: 'launch',
                          payload: {"id": "netflix"});
                    },
                    child: const Text(
                      'Launch Netflix',
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
                      callOneReply(
                          uri: 'luna://com.webos.applicationManager',
                          method: 'launch',
                          payload: {"id": "youtube.leanback.v4"});
                    },
                    child: const Text(
                      'Launch YouTube',
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
                      callOneReply(
                          uri: 'luna://com.webos.applicationManager',
                          method: 'launch',
                          payload: {"id": "amazon"});
                    },
                    child: const Text(
                      'Launch amazon prime',
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
                      callOneReply(
                          uri: 'luna://com.webos.applicationManager',
                          method: 'launch',
                          payload: {"id": "cj.eandm"});
                    },
                    child: const Text(
                      'Launch tving',
                      style: TextStyle(
                        fontSize: 27,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'LG Smart UI',
                      ),
                    ),
                  ),
                  // 쿠팡플레이: coupangplay
                  // LG채널: com.webos.app.lgchannels
                  // 디즈니플러스: com.disney.disneyplus-prod
                  // 왓챠: com.frograms.watchaplay.webos
                  const SizedBox(width: 16),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
