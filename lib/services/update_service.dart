import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:updater/updater.dart';
import '../services/log_service.dart';
/*
class UpdateService extends GetxService {
  late UpdaterController _updaterController;
  late Updater updater;
  var appCurrentVersion = ''.obs;
  var appNewVersion = ''.obs;

  final LogService log = Get.find<LogService>();

  Future<UpdateService> onInit() async {
    super.onInit();

    _updaterController = UpdaterController(
      listener: (UpdateStatus status) {
        switch (status) {
          case UpdateStatus.Available:
            log.printLog('Listener: Доступна новая версия!');
            break;
          case UpdateStatus.Checking:
            log.printLog('Listener: Проверка новой версии!');
            break;
          case UpdateStatus.Cancelled:
            log.printLog('Listener: Отмена');
            break;
          case UpdateStatus.Completed:
            log.printLog('Listener: Завершено');
            break;
          case UpdateStatus.Dowloading:
            log.printLog('Listener: Загрузка');
            break;
          case UpdateStatus.Failed:
            log.printLog('Listener: Ошибка при обновлении!');
            break;
          case UpdateStatus.DialogDismissed:
            log.printLog('Listener: Обновление отклонено!');
            break;
          case UpdateStatus.Paused:
            log.printLog('Listener: Пауза');
            break;
          case UpdateStatus.Resume:
            log.printLog('Listener: Продолжение');
            break;
          case UpdateStatus.Pending:
            log.printLog('Listener: Ожидание');
            break;
          default:
        }
      },
      onChecked: (bool isAvailable) {
        //log.printLog('isAvailable: $isAvailable     Доступна новая версия!');
      },
      progress: (current, total) {
        //log.printLog('Progress: $current -- $total');
      },
      onError: (status) {
        log.printLog('Error: $status');
      },
    );
    return this;
  }

  @override
  void onClose() {
    _updaterController.dispose();
    super.onClose();
  }

  Future<void> checkOTAUpdate(BuildContext context) async {
    try {
      VersionModel verModel = await getAppVersion();
      appCurrentVersion.value = '${verModel.version}.${verModel.buildNumber}';
    } catch (e) {
      log.printLog("Ошибка getAppVersion: $e");
    }

    updater = Updater(
      context: context,
      delay: const Duration(milliseconds: 300),
      url: 'https://achernyadev.com/updates/maggio/maggio-smart.json',
      allowSkip: true,
      enableResume: true,
      rootNavigator: true,
      backgroundDownload: false,
      controller: _updaterController,
      titleText: 'Обновление',
      contentText: 'Обновление приложения до последней версии \nТекущая версия: ${appCurrentVersion.value}',
      confirmText: 'Обновить',
      cancelText: 'Пропустить',
      callBack: (UpdateModel model) {
        appNewVersion.value = "${model.versionName}.${model.versionCode}";
        //log.printLog(model.versionName);
        //log.printLog(model.versionCode.toString());
        //log.printLog(model.contentText);
      },
    );
    try {
      //log.printLog('Текущая версия: ${appCurrentVersion.value}');
      await updater.check(withDialog: false);
    } catch (e) {
      log.printLog("Нет соединения с интернетом");
    }
    //To cancel the download
    //_updaterController.cancel();

    //To pause the download
    //_updaterController.pause();

    //To resume the download
    //_updaterController.resume();
  }
}
*/