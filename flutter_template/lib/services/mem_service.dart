import 'package:fluttertemplate/webos_service_helper/utils.dart';

class MemService {
  static int? _procStatSubscription;
  static int? _unitListSubscription;

  static int subscribeProcStat({
    required void Function(Map<String, dynamic>) onComplete,
    void Function(Object)? onError,
    void Function()? onDone,
  }) {
    _procStatSubscription = subscribe(
      uri: 'luna://com.webos.memorymanager',
      method: 'getProcStat',
      payload: {'subscribe': true},
      onComplete: onComplete,
      onError: onError,
      onDone: onDone,
    );
    return _procStatSubscription!;
  }

  static int subscribeUnitList({
    required void Function(Map<String, dynamic>) onComplete,
    void Function(Object)? onError,
    void Function()? onDone,
  }) {
    _unitListSubscription = subscribe(
      uri: 'luna://com.webos.memorymanager',
      method: 'getUnitList',
      payload: {'subscribe': true, "procList": 10},
      onComplete: onComplete,
      onError: onError,
      onDone: onDone,
    );
    return _unitListSubscription!;
  }

  // 사용 예시
  static void startMonitoring() {
    // 프로세스 상태 모니터링
    subscribeProcStat(
      onComplete: (data) {
        print('ProcStat updated: $data');
      },
      onError: (error) {
        print('ProcStat error: $error');
      },
    );

    // 유닛 리스트 모니터링
    subscribeUnitList(
      onComplete: (data) {
        print('UnitList updated: $data');
      },
      onError: (error) {
        print('UnitList error: $error');
      },
    );
  }

  // 구독 해제
  static void stopMonitoring() {
    if (_procStatSubscription != null) {
      cancel(_procStatSubscription!);
      _procStatSubscription = null;
    }
    if (_unitListSubscription != null) {
      cancel(_unitListSubscription!);
      _unitListSubscription = null;
    }
  }
}
