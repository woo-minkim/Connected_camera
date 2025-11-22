import 'package:flutter/foundation.dart';

import 'package:fluttertemplate/webos_service_helper/utils.dart';

class VolumeService {
  Future<int> getVolumeLevel() async {
    try {
      final res = await callOneReply(
        uri: 'luna://com.webos.audio/volume',
        method: 'getVolume',
        payload: {'subscribe': false},
      );
      final dynamic volume =
          res?['volume'] ?? res?['volumeStatus']?['volume'];
      if (volume is int) return volume;
      if (volume is num) return volume.round();
    } catch (error) {
      debugPrint('Volume fetch failed: $error');
    }
    return 15;
  }

  Future<void> setVolumeLevel(int level) async {
    final safeValue = level.clamp(0, 100);
    try {
      await callOneReply(
        uri: 'luna://com.webos.audio/volume',
        method: 'setVolume',
        payload: {'volume': safeValue},
      );
    } catch (error) {
      debugPrint('Volume set failed: $error');
    }
  }
}
