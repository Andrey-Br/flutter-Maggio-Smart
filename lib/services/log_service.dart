import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class LogService extends GetxService {
  var logText = [].obs;

  void printLog(String log) {
    debugPrint(log);

    logText.insert(0, log);
    if (logText.length > 50) {
      logText.removeAt(logText.length - 1);
    }
  }
}
