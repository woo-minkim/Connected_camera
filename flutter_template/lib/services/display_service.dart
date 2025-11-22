import 'package:flutter/foundation.dart';

import 'package:fluttertemplate/webos_service_helper/utils.dart';

class DisplayService {
  Future<int> getBrightnessLevel() async {
    try {
      final res = await callOneReply(
        uri: 'luna://com.webos.settingsservice',
        method: 'getSystemSettings',
        payload: {
          'category': 'picture',
          'keys': ['brightness'],
        },
      );
      final settings = res?['settings'];
      if (settings is List && settings.isNotEmpty) {
        final value = settings.first['value'];
        if (value is int) return value;
        if (value is num) return value.round();
        if (value is String) return int.tryParse(value) ?? 60;
      }
    } catch (error) {
      debugPrint('Failed to get brightness: $error');
    }
    return 60;
  }

  Future<Map<String, dynamic>?> setBrightnessLevel(int value) async {
    final int safeValue = value.clamp(10, 100);
    try {
      return await callOneReply(
        uri: 'luna://com.webos.settingsservice',
        method: 'setSystemSettings',
        payload: {
          'category': 'picture',
          'settings': [
            {'key': 'brightness', 'value': safeValue}
          ],
        },
      );
    } catch (error) {
      debugPrint('Failed to set brightness: $error');
      return null;
    }
  }
}
