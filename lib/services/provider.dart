import 'dart:convert';
import 'package:get/get.dart';
import '../variables/keys.dart';
import '../models/settings.dart';
import '../services/storage_service.dart';

class AppProvider {
  final StorageService _storageService = Get.find<StorageService>();

  List<AppSettings> readSettings() {
    var settings = <AppSettings>[];
    jsonDecode(_storageService.read(settingsKey).toString()).forEach((e) => settings.add(AppSettings.fromJson(e)));
    return settings;
  }

  void writeSettings(List<AppSettings> settings) {
    _storageService.write(settingsKey, jsonEncode(settings));
  }
}
