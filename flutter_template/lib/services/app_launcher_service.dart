import 'package:flutter/foundation.dart';

import 'package:fluttertemplate/webos_service_helper/utils.dart';

class AppLauncherService {
  const AppLauncherService();

  Future<Map<String, dynamic>?> launchApp(
    String appId, {
    List<String> fallbacks = const [],
  }) async {
    final ids = <String>{appId, ...fallbacks};
    for (final candidate in ids) {
      try {
        final result = await callOneReply(
          uri: 'luna://com.webos.applicationManager',
          method: 'launch',
          payload: {'id': candidate},
        );
        final success = result == null || result['returnValue'] != false;
        if (success) {
          return result;
        }
      } catch (error) {
        debugPrint('Failed to launch $candidate: $error');
      }
    }
    return null;
  }
}
