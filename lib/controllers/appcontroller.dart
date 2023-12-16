// ignore_for_file: avoid_log.printLog

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../models/settings.dart';
import '../variables/colors.dart';
import '../services/repository.dart';
import '../services/usb_service.dart';
import '../services/blu_service.dart';
import '../services/log_service.dart';
import '../variables/arduino.dart';
import '../widgets/snackbar.dart';
//import '../widgets/tabbuttons.dart';

class AppController extends GetxController {
  static const int CURRENT_STEP_WAITING = 0;
  static const int CURRENT_STEP_NAGREV = 1;
  static const int CURRENT_STEP_VIDERZHKA = 2;
  static const int CURRENT_STEP_OXLAZHDENIE = 3;
  static const int CURRENT_STEP_PODDERZHANIE = 4;
  static const int CURRENT_STEP_PAUSE = 5;

  SettingsRepository repository;
  AppController({required this.repository});

  Timer? _timer, _timerStatus, _timerOxlazhdenie, _timerApp, _commonTimer;

  late BuildContext appContext;

  // Текущий этап работы
  var currentStep = CURRENT_STEP_WAITING.obs;

  // Первый раз словил команду. Для прогрева после краша
  var firstLaunch = true;

  // Название выбранного рецепта
  var currentReceptName = "".obs;

  // Температура молока
  var currentTempMilk = 20.0.obs;

  // Температура воды
  var currentTempWater = 20.0.obs;

  // Выбран этап (нагрев, выдержка, охлаждение)
  var selectNagrev = false.obs;
  var selectViderzhka = false.obs;
  var selectOxlazhdenie = false.obs;
  var selectPodderzhanie = false.obs;

  // Блокировка этапа (когда в работе)
  var blockNagrev = false.obs;
  var blockViderzhka = false.obs;
  var blockOxlazhdenie = false.obs;
  var blockPodderzhanie = false.obs;

  // Установленная темп. и мощность нагрева
  var nagrevTemp = 80.0.obs;
  var nagrevPower = 2.obs; // (1,2,3)
  // Установленная выдержка (секунд)
  var viderzhkaTime = 0.obs;
  // Время выдержки  (секунд)
  var currentViderzhka = 0.obs;
  // Таймер обратного отсчета (секунд)
  var appTimer = 0.obs;
  // Таймер работы сыроварни (секунд)
  var commonTimer = 0.obs;

  // Установленная темп. охлаждения
  var oxlazhdenieTemp = 10.0.obs;
  // Установленная темп. поддержания
  var podderzhanieTemp = 50.0.obs;

  // Выбрана (включена) мешалка
  var selectMeshalka = false.obs;
  // Автореверс (вкл/выкл)
  var mixerAuto = true.obs;
  // Скорость мешалки (%)
  var mixerSpeed = 50.obs;
  // Время вращения (сек)
  var mixerTimeAuto = 10.obs;
  // Направление вращения (влево(0) / вправо(1))
  var mixerDirection = 0.obs;

  // Кнопка СТАРТ нажата
  var startPressed = false.obs;
  var startBtnText = 'msg_button_start'.tr.obs;

  // Параметры рецепта
  final settings = <AppSettings>[].obs;

  // Есть соединение с платой
  var deviceConnect = false.obs;
  // Соединение по USB
  var isUSBConnected = false.obs;
  // Соединение по Bluetooth
  var isBLUConnected = false.obs;
  // Звуки (вкл/выкл)
  var isSoundEnable = true.obs;
  // Язык интерфейса (русский(0) / английский(1))
  var currentLang = 0.obs;
  // Уровень громкости
  var currentVolume = 50.obs;
  // Нажатие "Красной кнопки"
  var isRedButtonPressed = false.obs;
  // Заполнение рубашки водой
  var isWaterFill = false.obs;
  // Открыт красный диалог
  var isRedButtenDialogOpen = false.obs;

  static AppController get to => Get.find();
  final LogService log = Get.find<LogService>();
  final UsbService usb = Get.find<UsbService>();
  final BluetoothService blu = Get.find<BluetoothService>();

  final CustomSnackbarController sb = Get.put(CustomSnackbarController());

  @override
  void onInit() {
    super.onInit();
    settings.assignAll(repository.readSettings());
    ever(settings, (_) => repository.writeSettings(settings));

    // Проверяем статус подключения

    // ==== ЗАКОММЕНТИРОВАНО === ИСПОЛЬЗОВАНИЕ BLUETOOTH

    _timerStatus = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (blu.isConnected()) {
        isBLUConnected.value = true;
        isUSBConnected.value = false;
        //usb.onClose();
        if (!deviceConnect.value) {
          if (!firstLaunch && (currentStep.value == CURRENT_STEP_WAITING)) {
            arduinoInit();
          }
        }
        deviceConnect.value = true;
        return;
      } else {
        //usb.init();
        isBLUConnected.value = false;
      }

      if (usb.status.value == UsbStatus.connect) {
        isUSBConnected.value = true;
        isBLUConnected.value = false;
        if (!deviceConnect.value) {
          if (!firstLaunch && (currentStep.value == CURRENT_STEP_WAITING)) {
            arduinoInit();
          }
        }
        deviceConnect.value = true;
        return;
      } else {
        isUSBConnected.value = false;
      }
      deviceConnect.value = false;
      firstLaunch = true;
    });

/*     _timerStatus = Timer.periodic(const Duration(seconds: 2), (timer) async {
      isBLUConnected.value = blu.isConnected();
      isUSBConnected.value = (usb.status.value == UsbStatus.connect) && !isBLUConnected.value;
      deviceConnect.value = isBLUConnected.value || isUSBConnected.value;

      if (!deviceConnect.value) {
        firstLaunch = true;
        return;
      }
      if (firstLaunch) {
        if (isBLUConnected.value && blu.serialData.isNotEmpty) {
          log.printLog("${blu.serialData[0]}");
          getCommandFirstLaunch(blu.serialData[0].toString());
          blu.serialData.removeAt(0);
        } else if (isUSBConnected.value && usb.serialData.isNotEmpty) {
          log.printLog("${usb.serialData[0]}");
          getCommandFirstLaunch(usb.serialData[0].toString());
          usb.serialData.removeAt(0);
        }
      }
      firstLaunch = false; 
*/

/*       if (!deviceConnect.value) {
        if (!firstLaunch && (currentStep.value == CURRENT_STEP_WAITING)) {
          arduinoInit();
        }
        return;
      } */
    //  });

    // Обрабатываем приходящие команды
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (isBLUConnected.value && blu.serialData.isNotEmpty) {
        log.printLog("${blu.serialData[0]}");
        doCommand(blu.serialData[0].toString());
        blu.serialData.removeAt(0);
      } else if (isUSBConnected.value && usb.serialData.isNotEmpty) {
        log.printLog("${usb.serialData[0]}");
        doCommand(usb.serialData[0].toString());
        usb.serialData.removeAt(0);
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    _timerStatus?.cancel();
    super.onClose();
  }

  /// * resetAllState()
  /// Сброс всех галок и кнопки "СТАРТ"
  ///
  void resetAllState() {
    selectNagrev.value = false;
    selectViderzhka.value = false;
    selectOxlazhdenie.value = false;
    selectMeshalka.value = false;
    selectPodderzhanie.value = false;
    currentViderzhka.value = 0;

    startBtnText.value = 'msg_button_start'.tr;
    startPressed.value = false;
    stopCommonTimer();
    if (currentStep.value != CURRENT_STEP_WAITING) writeCommand(Cmd.rs);
    currentStep.value = CURRENT_STEP_WAITING;
  }

  String currentStepToString(value) {
    switch (value) {
      case (CURRENT_STEP_WAITING):
        return 'msg_step_waiting'.tr;
      case (CURRENT_STEP_NAGREV):
        return 'msg_step_nagrev'.tr;
      case (CURRENT_STEP_VIDERZHKA):
        return 'msg_step_viderzhka'.tr;
      case (CURRENT_STEP_OXLAZHDENIE):
        return 'msg_step_oxlazhdenie'.tr;
      case (CURRENT_STEP_PODDERZHANIE):
        return 'msg_step_podderzhanie'.tr;
      case (CURRENT_STEP_PAUSE):
        return 'msg_step_pause'.tr;
      default:
        return 'msg_step_waiting'.tr;
    }
  }

  void writeCommand(String cmd) {
    if (isBLUConnected.value) {
      blu.bluWrite(cmd);
    } else if (isUSBConnected.value) {
      usb.usbWrite(cmd);
    }
  }

  /// * arduinoClear()
  /// Запись в плату нулевых значений
  ///
  ///void arduinoClear() {
  ///  writeCommand("${Cmd.state}0_${Cmd.hs}0_${Cmd.ts}0_${Cmd.ks}0_${Cmd.ma}0_${Cmd.ms}0_${Cmd.tn}000");
  ///}

  /// * arduinoInit()
  /// Инициализация платы настройками по умолчанию
  ///
  void arduinoInit() {
    var commands = '';

    switch (currentStep.value) {
      case CURRENT_STEP_WAITING:
        commands += "${Cmd.state}0";
        break;
      case CURRENT_STEP_NAGREV:
        commands += "${Cmd.state}1";
        break;
      case CURRENT_STEP_VIDERZHKA:
        commands += "${Cmd.state}2";
        break;
      case CURRENT_STEP_OXLAZHDENIE:
        commands += "${Cmd.state}3";
        break;
      case CURRENT_STEP_PODDERZHANIE:
        commands += "${Cmd.state}4";
        break;
      default:
    }

    commands += "_${Cmd.hs}${(nagrevTemp.value * 10).truncate()}";
    commands += "_${Cmd.ts}${viderzhkaTime.value}";
    commands += "_${Cmd.ks}${(oxlazhdenieTemp.value * 10).truncate()}";
    commands += "_${Cmd.hd}${(podderzhanieTemp.value * 10).truncate()}";

    switch (nagrevPower.value) {
      case 1:
        commands += "_${Cmd.tn}100";
        break;
      case 2:
        commands += "_${Cmd.tn}011";
        break;
      case 3:
        commands += "_${Cmd.tn}111";
        break;
      default:
    }

    commands += "_${Cmd.ma}0";
    commands += "_${Cmd.ms}0";

    writeCommand(commands);
  }

///// Инициализация после краша приложения //////
/////         Чтение данных с платы        //////
  ///
  void getCommandFirstLaunch(String cmdstr) {
    //
    log.printLog("Инициализация после краша!");
    //
    final commands = cmdstr.split('_');
    for (var cmd in commands) {
      String tmpstr = cmd;
      switch (cmd.substring(0, 2)) {
        case Cmd.hs: // Температура нагрева
          var temp = (double.parse(tmpstr.replaceAll(Cmd.hs, '')) / 10); //.round();
          if (temp != 0) {
            nagrevTemp.value = temp;
            selectNagrev.value = true;
            blockNagrev.value = true;
          }
          log.printLog("Инициализация Температура нагрева");
          break;

        case Cmd.tn: // Мощность нагрева
          var temp = tmpstr.replaceAll(Cmd.tn, '');
          switch (temp) {
            case '001':
              nagrevPower.value = 1;
              break;
            case '011':
              nagrevPower.value = 2;
              break;
            case '111':
              nagrevPower.value = 3;
              break;
            default:
          }
          log.printLog("Инициализация Мощность нагрева");
          break;

        case Cmd.ts: // Выдержка
          var temp = int.parse(tmpstr.replaceAll(Cmd.ts, ''));
          if (temp != 0) {
            selectViderzhka.value = true;
            viderzhkaTime.value = temp;
          }
          log.printLog("Инициализация Выдержка");
          break;

        case Cmd.ks: // Температура охлаждения
          var temp = (double.parse(tmpstr.replaceAll(Cmd.ks, '')) / 10); //.round();
          if (temp != 0) {
            selectOxlazhdenie.value = true;
            oxlazhdenieTemp.value = temp;
          }
          log.printLog("Инициализация охлаждения");
          break;

        case Cmd.hd: // Температура охлаждения
          var temp = (double.parse(tmpstr.replaceAll(Cmd.hd, '')) / 10); //.round();
          if (temp != 0) {
            selectPodderzhanie.value = true;
            podderzhanieTemp.value = temp;
          }
          log.printLog("Инициализация темп. поддержания");
          break;

        case Cmd.ms: // Скорость мешалки
          var temp = (int.parse(tmpstr.replaceAll(Cmd.ms, '')));
          mixerSpeed.value = temp;
          break;

        case Cmd.ma: // Автореверс
          var temp = (int.parse(tmpstr.replaceAll(Cmd.ma, '')));
          if (temp != 0) mixerAuto.value = true;
          mixerTimeAuto.value = temp;
          break;
        default:
      }
    }
  }

  void doCommand(String cmdstr) {
    final commands = cmdstr.split('_');
    for (var cmd in commands) {
      String tmpstr = cmd;
      switch (cmd.substring(0, 2)) {
        //Температура молока
        case Cmd.tm:
          var temp = (double.parse(tmpstr.replaceAll(Cmd.tm, '')) / 10);
          currentTempMilk.value = temp;
          break;
        //Температура воды
        case Cmd.tw:
          var temp = (double.parse(tmpstr.replaceAll(Cmd.tw, '')) / 10);
          currentTempWater.value = temp;
          break;
        //Нет воды в рубашке
        case Cmd.we:
          isWaterFill.value = false;
          break;
        //Вода в рубашке есть
        case Cmd.wf:
          isWaterFill.value = true;
          break;
        //Красная кнопка нажата
        case Cmd.rp:
          if (isRedButtonPressed.value != true) {
            sb.showCenterDialog(
              closeOnTapBG: false,
              windowColor: AppColors.colButtonStart,
              textColor: const Color.fromARGB(255, 248, 205, 205),
              iconPath: 'assets/icons/svg/icon_warning.svg',
              title: "Нажата кнопка СТОП",
              text: "Отключите кнопку для продолжения работы",
              soundPath: isSoundEnable.value ? 'assets/audio/ding.mp3' : null,
            );
            isRedButtenDialogOpen.value = true;
          }
          isRedButtonPressed.value = true;
          resetAllState();
          break;
        //Красная кнопка отжата
        case Cmd.rr:
          if (isRedButtonPressed.value == true && isRedButtenDialogOpen.value) Get.back();
          isRedButtenDialogOpen.value = false;
          //Future.delayed(const Duration(seconds: 1), () {
          isRedButtonPressed.value = false;
          //});
          //arduinoInit();
          break;
        //Текущий этап
        case Cmd.state:
          var temp = int.parse(tmpstr.replaceAll(Cmd.state, ''));
          currentStep.value = temp;

          switch (currentStep.value) {
            case CURRENT_STEP_WAITING:
              blockNagrev.value = false;
              blockViderzhka.value = false;
              blockOxlazhdenie.value = false;
              blockPodderzhanie.value = false;
              _timerOxlazhdenie != null ? {_timerOxlazhdenie?.cancel()} : {};
              break;
            case CURRENT_STEP_NAGREV:
              blockNagrev.value = true;
              break;
            case CURRENT_STEP_VIDERZHKA:
              blockViderzhka.value = true;
              break;
            case CURRENT_STEP_OXLAZHDENIE:
              if (blockOxlazhdenie.value != true) {
                // Выводим сообщение, что молоко больше не охладится
/*                 
                _timerOxlazhdenie = Timer.periodic(const Duration(seconds: 60), (timer) async {
                  log.printLog("currentTempWater:  ${currentTempWater.value}    currentTempMilk: ${currentTempMilk.value}");
                  if ((currentTempMilk.value - currentTempWater.value).abs() < 1) {
                    sb.showCenterDialog(
                      title: "Охлаждение молока",
                      text: "Температура молока достигла температуры воды из-под крана. Дальнейшее охлаждение молока невозможно.",
                      primaryBtnText: 'msg_button_complete'.tr,
                      secondaryBtnText: 'msg_button_resume'.tr,
                      soundPath: isSoundEnable.value ? 'assets/audio/ding.mp3' : null,
                      onPrimary: () {
                        writeCommand(Cmd.rs);
                        currentStep.value = CURRENT_STEP_WAITING;
                        _timerOxlazhdenie?.cancel();
                        startBtnText.value = 'msg_button_start'.tr;
                        startPressed.value = false;
                      },
                    );
                  }
                });
 */
                blockOxlazhdenie.value = true;
              }
              break;
            case CURRENT_STEP_PODDERZHANIE:
              blockPodderzhanie.value = true;
              break;
            default:
          }
          if (firstLaunch && (currentStep.value != CURRENT_STEP_WAITING)) {
            startBtnText.value = 'msg_button_stop'.tr;
            startPressed.value = true;
          }
          break;

        case Cmd.dh:
          if (selectNagrev.value) selectNagrev.toggle();
          sb.showNotification(
            'msg_notify_nagrev_ok'.tr,
            duration: 3,
            iconPath: 'assets/icons/svg/icon_warning.svg',
            soundPath: isSoundEnable.value ? 'assets/audio/msg_notify_nagrev_ok.mp3' : null,
          );
          log.printLog("Молоко нагрето до нужной температуры!!!");
          break;

        case Cmd.dd:
          if (selectViderzhka.value) selectViderzhka.toggle();
          currentViderzhka.value = 0;
          sb.showNotification(
            'msg_notify_nagrev_completed'.tr,
            duration: 3,
            iconPath: 'assets/icons/svg/icon_warning.svg',
            soundPath: isSoundEnable.value ? 'assets/audio/msg_notify_nagrev_completed.mp3' : null,
          );
          log.printLog("Выдержка завершена!!!");
          break;

        case Cmd.dc:
          if (selectOxlazhdenie.value) selectOxlazhdenie.toggle();
          _timerOxlazhdenie?.cancel();
          sb.showNotification(
            'msg_notify_oxlazhdenie_completed'.tr,
            duration: 3,
            iconPath: 'assets/icons/svg/icon_warning.svg',
            soundPath: isSoundEnable.value ? 'assets/audio/msg_notify_oxlazhdenie_completed.mp3' : null,
          );
          log.printLog("Охлаждение завершено!!!");
          break;

        case Cmd.da:
          log.printLog("Процесс приготовления завершен!");

          selectNagrev.value = false;
          selectViderzhka.value = false;
          selectOxlazhdenie.value = false;
          selectPodderzhanie.value = false;
          selectMeshalka.value = false;

          //arduinoClear();
          _timerOxlazhdenie?.cancel();
          startBtnText.value = 'msg_button_start'.tr;
          startPressed.value = false;

          stopCommonTimer();

          //currentStep.value = CURRENT_STEP_WAITING;
          sb.showNotification('msg_notify_all_completed'.tr,
              iconPath: 'assets/icons/svg/icon_warning.svg', soundPath: isSoundEnable.value ? 'assets/audio/msg_notify_all_completed.mp3' : null);
          break;

        // Выдержка (осталось)
        case Cmd.tl:
          //currentViderzhka.value = (viderzhkaTime.value * 60) - int.parse(tmpstr.replaceAll(Cmd.tl, ''));
          currentViderzhka.value = viderzhkaTime.value - int.parse(tmpstr.replaceAll(Cmd.tl, ''));
          break;

        ///// Инициализация после краша приложения //////
        /////         Чтение данных с платы        //////

        case Cmd.hs: // Температура нагрева
          if (firstLaunch && (currentStep.value != CURRENT_STEP_WAITING)) {
            var temp = (double.parse(tmpstr.replaceAll(Cmd.hs, '')) / 10); //.round();
            if (temp != 0) {
              nagrevTemp.value = temp;
              selectNagrev.value = true;
              blockNagrev.value = true;
            }
            log.printLog("Инициализация Температура нагрева $firstLaunch");
          }
          break;
        case Cmd.tn: // Мощность нагрева
          if (firstLaunch && (currentStep.value != CURRENT_STEP_WAITING)) {
            var temp = tmpstr.replaceAll(Cmd.tn, '');
            switch (temp) {
              case '001':
                nagrevPower.value = 1;
                break;
              case '011':
                nagrevPower.value = 2;
                break;
              case '111':
                nagrevPower.value = 3;
                break;
              default:
            }
            log.printLog("Инициализация Мощность нагрева $firstLaunch");
          }
          break;
        case Cmd.ts: // Выдержка
          if (firstLaunch && (currentStep.value != CURRENT_STEP_WAITING)) {
            //var temp = (int.parse(tmpstr.replaceAll(Cmd.ts, '')) / 60).round();
            var temp = int.parse(tmpstr.replaceAll(Cmd.ts, ''));
            if (temp != 0) {
              selectViderzhka.value = true;
              viderzhkaTime.value = temp;
            }
            log.printLog("Инициализация Выдержка $firstLaunch");
          }
          break;
        case Cmd.ks: // Температура охлаждения
          if (firstLaunch && (currentStep.value != CURRENT_STEP_WAITING)) {
            var temp = (double.parse(tmpstr.replaceAll(Cmd.ks, '')) / 10); //.round();
            if (temp != 0) {
              selectOxlazhdenie.value = true;
              oxlazhdenieTemp.value = temp;
            }
            log.printLog("Инициализация охлаждения $firstLaunch");
          }
          break;
/*         case Cmd.ms: // Скорость мешалки
          if (firstLaunch && (currentStep.value != CURRENT_STEP_WAITING)) {
            var temp = (int.parse(tmpstr.replaceAll(Cmd.ms, '')));
            mixerSpeed.value = temp;
          }
          break;
        case Cmd.ma: // Автореверс
          if (firstLaunch && (currentStep.value != CURRENT_STEP_WAITING)) {
            var temp = (int.parse(tmpstr.replaceAll(Cmd.ma, '')));
            if (temp != 0) mixerAuto.value = true;
            mixerTimeAuto.value = temp;
          }
          break; */

        // ЭНКОДЕР A
/*         case Cmd.ac: // Обычное нажатие
          //onSelectNagrev();
          break;
        case Cmd.ah: // Длинное нажатие
          break;
        case Cmd.ar: // Поворот направо
          break;
        case Cmd.al: // Поворот налево
          break;
        case Cmd.arh: // Поворот направо с нажатой кнопкой
          nagrevTemp = (nagrevTemp.value < 100) ? nagrevTemp++ : nagrevTemp;
          break;
        case Cmd.alh: // Поворот налево с нажатой кнопкой
          nagrevTemp = (nagrevTemp.value > currentTempMilk.value) ? nagrevTemp-- : nagrevTemp;
          break;
        case Cmd.an: // Количество кликов нажатое подряд ($temp)
          var temp = int.parse(tmpstr.substring(2));
          break;
        case Cmd.ad: // Долгое нажатие на ($temp) клике
          var temp = int.parse(tmpstr.substring(2));
          break;
        case Cmd.au: // Кнопка поднята после удержания
          changeTempNagrev(nagrevTemp.value);
          break;
 */
        // ЭНКОДЕР B
/*         case Cmd.bc: // Обычное нажатие
          //enBjumpPage();
          onSelectMeshalka();
          break;
        case Cmd.bh: // Длинное нажатие
          //enBjumpPage();
          togleMixerAuto(!mixerAuto.value);
          break;
        case Cmd.br: // Поворот направо
          //enBjumpPage();
          mixerSpeed.value = (mixerSpeed.value < 100) ? mixerSpeed.value + 10 : 100;
          changeMixerSpeed(mixerSpeed.value);
          break;
        case Cmd.bl: // Поворот налево
          //enBjumpPage();
          mixerSpeed.value = (mixerSpeed.value > 10) ? mixerSpeed.value - 10 : 0;
          changeMixerSpeed(mixerSpeed.value);
          break;
        case Cmd.brh: // Поворот направо с нажатой кнопкой
          //enBjumpPage();
          mixerTimeAuto.value = (mixerTimeAuto.value < 100) ? mixerTimeAuto.value + 5 : 100;
          break;
        case Cmd.blh: // Поворот налево с нажатой кнопкой
          //enBjumpPage();
          mixerTimeAuto.value = (mixerTimeAuto.value > 10) ? mixerTimeAuto.value - 5 : 0;
          break;
        case Cmd.bn: // Количество кликов нажатое подряд ($temp)
          //enBjumpPage();
          //var temp = int.parse(tmpstr.substring(2));
          break;
        case Cmd.bd: // Долгое нажатие на ($temp) клике
          //enBjumpPage();
          //var temp = int.parse(tmpstr.substring(2));
          break;
        case Cmd.bu: // Кнопка поднята после удержания
          //enBjumpPage();
          changeMixerTimeAuto(mixerTimeAuto.value);
          break; */

        default:
      }
    }
    firstLaunch = false;
  }

  void onPressedStartBtn() {
    if (deviceConnect.value) {
      if (selectNagrev.value || selectViderzhka.value || selectOxlazhdenie.value || selectPodderzhanie.value) {
        !startPressed.value ? startBtnText.value = 'msg_button_stop'.tr : startBtnText.value = 'msg_button_start'.tr;
        startPressed.toggle();

        if (startPressed.value) {
          String commands = '';

          if (selectViderzhka.value) {
            commands += "${Cmd.hs}${(nagrevTemp.value * 10).truncate()}";
            commands += "_${Cmd.ts}${viderzhkaTime.value}";
          } else {
            selectNagrev.value ? commands += "${Cmd.hs}${(nagrevTemp.value * 10).truncate()}" : commands += "${Cmd.hs}0";
            commands += "_${Cmd.ts}0";
          }

          selectOxlazhdenie.value ? commands += "_${Cmd.ks}${(oxlazhdenieTemp.value * 10).truncate()}" : commands += "_${Cmd.ks}0";
          selectPodderzhanie.value ? commands += "_${Cmd.hd}${(podderzhanieTemp.value * 10).truncate()}" : commands += "_${Cmd.hd}0";

          switch (nagrevPower.value) {
            case 1:
              commands += "_${Cmd.tn}100";
              break;
            case 2:
              commands += "_${Cmd.tn}011";
              break;
            case 3:
              commands += "_${Cmd.tn}111";
              break;
            default:
          }

          selectMeshalka.value ? commands += "_${Cmd.ms}${mixerSpeed.value}" : commands += "_${Cmd.ms}0";
          mixerAuto.value ? commands += "_${Cmd.ma}${mixerTimeAuto.value}" : commands += "_${Cmd.ma}0";

          if (commands != "") {
            writeCommand("${commands}_${Cmd.rc}");
            startCommonTimer();
          }
          log.printLog("СЫРОВАРНЯ ВКЛ");
        } else {
          writeCommand(Cmd.rs);
          currentStep.value = CURRENT_STEP_WAITING;
          stopCommonTimer();
          log.printLog("СЫРОВАРНЯ ВЫКЛ");
        }
      } else {
        if (!startPressed.value) {
          sb.showNotification(
            'msg_notify_no_start'.tr,
            iconPath: 'assets/icons/svg/icon_warning.svg',
            soundPath: isSoundEnable.value ? 'assets/audio/msg_notify_no_start.mp3' : null,
          );
        } else {
          _timerOxlazhdenie?.cancel();
          stopCommonTimer();
          startBtnText.value = 'msg_button_start'.tr;
          startPressed.value = false;
        }
      }
    } else {
      sb.showNotification(
        'msg_notify_connection_error'.tr,
        iconPath: 'assets/icons/svg/icon_warning.svg',
        soundPath: isSoundEnable.value ? 'assets/audio/ding.mp3' : null,
      );
    }
  }

  // ЭНКОДЕР A НАВИГАЦИЯ
/*   void enAjumpPage() {
    //if (ctc.selectedPage.value != 3) ctc.changePage(3);
  } */

  // ЭНКОДЕР В ПОДСВЕЧИВАЕТ МЕШАЛКУ
/*   void enBjumpPage() {
    //if (ctc.selectedPage.value != 3) ctc.changePage(3);
  } */

  // НАГРЕВ ВКЛ/ВЫКЛ
  void onSelectNagrev() {
    selectNagrev.toggle();
    selectNagrev.value
        ? {writeCommand("${Cmd.hs}${(nagrevTemp.value * 10).truncate()}"), log.printLog("НАГРЕВ ВКЛ")}
        : {writeCommand("${Cmd.hs}0"), log.printLog("НАГРЕВ ВЫКЛ")};
  }

  // ВЫДЕРЖКА ВКЛ/ВЫКЛ
  void onSelectViderzhka() {
    selectViderzhka.toggle();
    selectViderzhka.value
        ? {writeCommand("${Cmd.ts}${viderzhkaTime.value}"), log.printLog("ВЫДЕРЖКА ВКЛ")}
        : {writeCommand("${Cmd.ts}0"), log.printLog("ВЫДЕРЖКА ВЫКЛ")};
  }

  // ОХЛАЖДЕНИЕ ВКЛ/ВЫКЛ
  void onSelectOxlazhdenie() {
    selectOxlazhdenie.toggle();
    selectOxlazhdenie.value
        ? {writeCommand("${Cmd.ks}${(oxlazhdenieTemp.value * 10).truncate()}"), log.printLog("ОХЛАЖДЕНИЕ ВКЛ")}
        : {writeCommand("${Cmd.ks}0"), log.printLog("ОХЛАЖДЕНИЕ ВЫКЛ")};
  }

  // ПОДДЕРЖАНИЕ ТЕМПЕРАТУРЫ ВКЛ/ВЫКЛ
  void onSelectPodderzhanie() {
    selectPodderzhanie.toggle();
    selectPodderzhanie.value
        ? {writeCommand("${Cmd.hd}${(podderzhanieTemp.value * 10).truncate()}"), log.printLog("ПОДДЕРЖАНИЕ ВКЛ")}
        : {writeCommand("${Cmd.hd}0"), log.printLog("ПОДДЕРЖАНИЕ ВЫКЛ")};
  }

  // МЕШАЛКА ВКЛ/ВЫКЛ
  void onSelectMeshalka() {
    String cmd = "";
    selectMeshalka.toggle();
    selectMeshalka.value ? {cmd += "${Cmd.ms}${mixerSpeed.value}", log.printLog("МЕШАЛКА ВКЛ")} : {cmd += "${Cmd.ms}0", log.printLog("МЕШАЛКА ВЫКЛ")};
    mixerAuto.value ? {cmd += "_${Cmd.ma}${mixerTimeAuto.value}"} : {cmd += "${Cmd.ma}0"};
    writeCommand(cmd);
  }

  // ТЕМПЕРАТУРА НАГРЕВА
  void changeTempNagrev(double temp) {
    nagrevTemp.value = temp;
    writeCommand("${Cmd.hs}${(temp * 10).truncate()}");
    log.printLog("Температура нагрева: $temp");
  }

  // ТЕМПЕРАТУРА ПОДДЕРЖАНИЯ
  void changeTempPodderzhanie(double temp) {
    podderzhanieTemp.value = temp;
    writeCommand("${Cmd.hd}${(temp * 10).truncate()}");
    log.printLog("Температура поддержания: $temp");
  }

  // НАПРАВЛЕНИЕ ВРАЩЕНИЯ МЕШАЛКИ (0/1)
  void changeMixerDirection(int dir) {
    mixerDirection.value = dir;
    writeCommand(Cmd.md + dir.toString());
    if (dir == 0) {
      log.printLog("Направление вращения: ВЛЕВО");
    } else if (dir == 1) {
      log.printLog("Направление вращения: ВПРАВО");
    }
  }

  // МОЩНОСТЬ НАГРЕВА (КОЛ-ВО ТЭНОВ)
  void changeTempPower(int pow) {
    nagrevPower.value = pow + 1;
    switch (nagrevPower.value) {
      case 1:
        writeCommand("${Cmd.tn}100");
        log.printLog("+ТЭН1  -ТЭН2  -ТЭН3");
        break;
      case 2:
        writeCommand("${Cmd.tn}011");
        log.printLog("-ТЭН1  +ТЭН2  +ТЭН3");
        break;
      case 3:
        writeCommand("${Cmd.tn}111");
        log.printLog("+ТЭН1  +ТЭН2  +ТЭН3");
        break;
      default:
    }
  }

  // ВРЕМЯ ВЫДЕРЖКИ, сек
  void changeViderzhka(int time) {
    viderzhkaTime.value = time;
    writeCommand(Cmd.ts + time.toString());

    log.printLog("Время выдержки: $time");
  }

  // ТЕМПЕРАТУРА ОХЛАЖДЕНИЯ
  void changeTempOxlazhdenie(double temp) {
    oxlazhdenieTemp.value = temp;
    writeCommand("${Cmd.ks}${(temp * 10).truncate()}");
    log.printLog("Температура охлаждения: $temp");
  }

  // АВТОРЕВЕРС ВКЛ/ВЫКЛ
  void togleMixerAuto(bool val) {
    mixerAuto.value = val;
    val ? writeCommand(Cmd.ma + mixerTimeAuto.value.toString()) : writeCommand("${Cmd.ma}0");
    log.printLog("Автореверс: ${mixerAuto.value}");
  }

  // СКОРОСТЬ МЕШАЛКИ 0..100%
  void changeMixerSpeed(int speed) {
    mixerSpeed.value = speed;

    if (selectMeshalka.value) writeCommand(Cmd.ms + speed.toString());
    if (mixerSpeed.value <= 0) selectMeshalka.value = false;
    log.printLog("Скорость мешалки: $speed");
  }

  // ВРЕМЯ АВТОРЕВЕРСА, сек
  void changeMixerTimeAuto(int time) {
    mixerTimeAuto.value = time;
    if (mixerAuto.value) writeCommand(Cmd.ma + mixerTimeAuto.value.toString());
    if (mixerTimeAuto.value <= 0) mixerAuto.value = false;
    log.printLog("Время автореверса: $time");
  }

  // КАЛИБРОВКА ДАТЧИКОВ
  void calibrateSensor(String command, String temp) {
    var t = 0;
    try {
      temp.isNotEmpty && temp != '.' ? t = (num.parse(temp) * 10).round() : t = 0;
    } catch (_) {}

    if (t < 0 || t > 1000) {
      sb.showNotification(
        'msg_notify_temp_error'.tr,
        iconPath: 'assets/icons/svg/icon_warning.svg',
      );
    } else {
      switch (command) {
        case "S1":
          writeCommand(Cmd.s1 + t.toString());
          break;
        case "S2":
          writeCommand(Cmd.s2 + t.toString());
          break;
        case "S3":
          writeCommand(Cmd.s3 + t.toString());
          break;
        case "S4":
          writeCommand(Cmd.s4 + t.toString());
          break;
        default:
      }
      sb.showNotification(
        'msg_notify_success'.tr,
        duration: 3,
        iconPath: 'assets/icons/svg/icon_success.svg',
      );
    }
  }

  // СБРОС ЗНАЧЕНИЙ ДАТЧИКОВ ПО УМОЛЧАНИЮ
  void resetSensor(BuildContext context) {
    sb
        .showCenterDialog(
      title: "Сброс",
      text: 'msg_settings_calibr_reset'.tr,
      primaryBtnText: 'msg_button_set'.tr,
      secondaryBtnText: 'msg_button_cancel'.tr,
      soundPath: isSoundEnable.value ? 'assets/audio/ding.mp3' : null,
      onPrimary: () {
        writeCommand(Cmd.sr);
      },
    )
        .then((result) {
      if (result) sb.showNotification('msg_notify_calibr_reset'.tr, iconPath: 'assets/icons/svg/icon_warning.svg', duration: 3);
    });
  }

  void addSettings(AppSettings setting) {
    settings.insert(0, setting);
  }

  void removeSettings(int item) {
    settings.removeAt(item);
  }

  void setSettings(int item) {
    currentReceptName.value = settings[item].receptName;
    selectNagrev.value = settings[item].selectNagrev;
    selectViderzhka.value = settings[item].selectViderzhka;
    selectOxlazhdenie.value = settings[item].selectOxlazhdenie;
    selectMeshalka.value = settings[item].selectMeshalka;
    nagrevTemp.value = settings[item].nagrevTemp.toDouble();
    nagrevPower.value = settings[item].nagrevPower;
    viderzhkaTime.value = settings[item].viderzhkaTime;
    oxlazhdenieTemp.value = settings[item].oxlazhdenieTemp.toDouble();
    mixerAuto.value = settings[item].mixerAuto;
    mixerSpeed.value = settings[item].mixerSpeed;
    mixerTimeAuto.value = settings[item].mixerTimeAuto;
  }

  bool checkReceptName(String name) {
    for (var item in settings) {
      if (name == item.receptName) {
        return true;
      }
    }
    return false;
  }

  List<String> getViderzhka4List() {
    var listHelper = <String>[];
    int i = 1;

    for (var item in settings) {
      if (item.viderzhkaTime > 0) {
        if (!listHelper.contains(item.viderzhkaTime.toString())) {
          listHelper.add(item.viderzhkaTime.toString());
          i++;
        }
      }
      if (i > 4) return listHelper;
    }
    return listHelper;
  }

  List<String> getOxlazhdenie4List() {
    var listHelper = <String>[];
    int i = 1;

    for (var item in settings) {
      if (item.oxlazhdenieTemp > 0) {
        if (!listHelper.contains(item.oxlazhdenieTemp.toString())) {
          listHelper.add(item.oxlazhdenieTemp.toString());
          i++;
        }
      }
      if (i > 4) return listHelper;
    }
    return listHelper;
  }

  String getTime(int seconds) {
    int h, m, s;

    h = seconds ~/ 3600;
    m = (seconds - (h * 3600)) ~/ 60;
    s = seconds - (h * 3600) - (m * 60);

    String hourLeft = h.toString();
    String minuteLeft = m.toString().length < 2 ? "0${m.toString()}" : m.toString();
    String secondsLeft = s.toString().length < 2 ? "0${s.toString()}" : s.toString();

    return "$hourLeft:$minuteLeft:$secondsLeft";
  }

  void startCommonTimer() {
    // commonTimer.value = 0;
    // _commonTimer?.cancel();
    _commonTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      commonTimer.value < 86400 ? commonTimer.value++ : commonTimer.value = 0;
    });
  }

  void stopCommonTimer() {
    commonTimer.value = 0;
    _commonTimer?.cancel();
  }

  void startTimerApp(int seconds) {
    appTimer.value = seconds;
    _timerApp = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (appTimer.value > 0) {
        appTimer.value--;
      } else {
        _timerApp?.cancel();
        sb.showCenterDialog(
          title: "Оповещение",
          text: "Время вышло!",
          primaryBtnText: 'msg_button_close'.tr,
          soundPath: isSoundEnable.value ? 'assets/audio/ding.mp3' : null,
          onPrimary: () {
            appTimer.value = 0;
            Get.back();
          },
        );
      }
    });
  }

  void stopTimerApp() {
    appTimer.value = 0;
    _timerApp?.cancel();
  }
}
