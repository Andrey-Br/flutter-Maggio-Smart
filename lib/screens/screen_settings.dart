import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:system_settings/system_settings.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:install_plugin_v2/install_plugin_v2.dart';
import '../controllers/appcontroller.dart';
//import '../services/update_service.dart';
import '../widgets/select_btn.dart';
import '../widgets/slider.dart';
import '../widgets/keyboard.dart';
import '../variables/colors.dart';
import '../services/log_service.dart';

class MainSettingsController extends GetxController {
  var langName = 'msg_settings_lang_ru'.tr.obs;
  final langs = [
    'msg_settings_lang_ru'.tr,
    'msg_settings_lang_en'.tr,
  ];

  var calibrHIValue = "".obs;
  var calibrLOValue = "".obs;
  late BuildContext _context;
  late BuildContext _context_unfocus;
  final focusHI = false.obs;
  final focusLO = false.obs;
  final disableBtnHI = true.obs;
  final disableBtnLO = true.obs;
  final _textFieldErrorHI = false.obs;
  final _textFieldErrorLO = false.obs;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNodeHI = FocusNode();
  final FocusNode _focusNodeLO = FocusNode();
  final TextEditingController _textControllerHI = TextEditingController();
  final TextEditingController _textControllerLO = TextEditingController();

  final appc = Get.find<AppController>();
  final LogService log = Get.find<LogService>();

  late String updatePath = "";
  var appCurrentInfo = <String, String>{
    "version": "",
    "buildNumber": "",
    "appName": "",
    "packageName": "",
  }.obs;
  //final UpdateService upd = Get.put(UpdateService());

  @override
  void onInit() async {
    super.onInit();
    _focusNodeHI.addListener(_onFocusChange);
    _focusNodeLO.addListener(_onFocusChange);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appCurrentInfo['version'] = packageInfo.version;
    appCurrentInfo['buildNumber'] = packageInfo.buildNumber;
    appCurrentInfo['appName'] = packageInfo.appName;
    appCurrentInfo['packageName'] = packageInfo.packageName;

    VolumeController().listener((volume) {
      appc.currentVolume.value = (volume * 100).truncate();
    });

    VolumeController().getVolume().then((volume) => appc.currentVolume.value = (volume * 100).truncate());
  }

  @override
  void onClose() {
    calibrHIValue.value = '';
    calibrLOValue.value = '';
    _textControllerHI.clear();
    _textControllerLO.clear();
    _textControllerHI.dispose();
    _textControllerLO.dispose();
    _focusNodeHI.removeListener(_onFocusChange);
    _focusNodeLO.removeListener(_onFocusChange);
    _focusNodeLO.dispose();
    _focusNodeHI.dispose();
    VolumeController().removeListener();
    super.onClose();
  }

  void _unFocus(BuildContext context) {
    try {
      FocusScope.of(context).unfocus();
      if (_focusNodeHI.hasFocus || _focusNodeLO.hasFocus) {
        Navigator.pop(context);
      }
    } catch (_) {}
  }

  void _onFocusChange() {
    if (_focusNodeHI.hasFocus || _focusNodeLO.hasFocus) {
      showBottomSheet(
        context: _context,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (context) => VirtualKeyboard(height: 150, fontSize: 28, textColor: Colors.white, type: VirtualKeyboardType.Numeric, onKeyPress: _onKeyPress),
      );
/*       Get.bottomSheet(
        VirtualKeyboard(height: 150, fontSize: 28, textColor: Colors.white, type: VirtualKeyboardType.Numeric, onKeyPress: _onKeyPress),
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        enableDrag: false,
        isDismissible: false,
        ignoreSafeArea: true,
      ); */
    } else {
      //Navigator.pop(_context);
    }
  }

  _isError(String val) {
    var t = 0.0;
    try {
      val.isNotEmpty && val != '.' ? t = (num.parse(val) * 10).round() / 10 : t = 0;
    } catch (_) {}
    return (t <= 0 || t > 100) ? true : false;
  }

  _onKeyPress(VirtualKeyboardKey key) {
    if (_focusNodeHI.hasFocus) {
      if (key.keyType == VirtualKeyboardKeyType.String) {
        calibrHIValue.value = calibrHIValue.value + key.text;
      } else if (key.keyType == VirtualKeyboardKeyType.Action) {
        switch (key.action) {
          case VirtualKeyboardKeyAction.Backspace:
            if (calibrHIValue.value.isEmpty) return;
            calibrHIValue.value = calibrHIValue.value.substring(0, calibrHIValue.value.length - 1);
            break;
          case VirtualKeyboardKeyAction.Confirm:
            if (_focusNodeHI.hasFocus || _focusNodeLO.hasFocus) {
              _unFocus(_context_unfocus);
            }
            break;
          default:
        }
      }
      _textControllerHI.text = calibrHIValue.value.toString();
      _textControllerHI.selection = TextSelection.collapsed(offset: _textControllerHI.text.length);
    } else if (_focusNodeLO.hasFocus) {
      if (key.keyType == VirtualKeyboardKeyType.String) {
        calibrLOValue.value = calibrLOValue.value + key.text;
      } else if (key.keyType == VirtualKeyboardKeyType.Action) {
        switch (key.action) {
          case VirtualKeyboardKeyAction.Backspace:
            if (calibrLOValue.value.isEmpty) return;
            calibrLOValue.value = calibrLOValue.value.substring(0, calibrLOValue.value.length - 1);
            break;
          case VirtualKeyboardKeyAction.Confirm:
            if (_focusNodeHI.hasFocus || _focusNodeLO.hasFocus) {
              _unFocus(_context_unfocus);
            }
            break;
          default:
        }
      }
      _textControllerLO.text = calibrLOValue.value.toString();
      _textControllerLO.selection = TextSelection.collapsed(offset: _textControllerLO.text.length);
    }
  }

  void _onLangChange(val) {
    if (val == 0) {
      var locale = const Locale('ru', 'RU');
      Get.updateLocale(locale);
    } else if (val == 1) {
      var locale = const Locale('en', 'US');
      Get.updateLocale(locale);
    }
    appc.currentLang.value = val;
    langName.value = langs.elementAt(val);
  }

  void checkForUpdates() async {
    String pathToFlashDrive = '/storage/udisk2/MIAUPD';

    try {
      var dir = Directory(pathToFlashDrive);
      if (dir.existsSync()) {
        // Если директория на флешке существует - ищем там обновление
        var files = dir.listSync();
        for (var file in files) {
          if (file.path.endsWith('.apk') && file.path.contains('maggio')) {
            // Если найден файл с новой версией - обновляемся
            //String localFilePath = file.path;
            log.printLog("Найдено обновление: ${file.path}");
            updatePath = file.path;
          }
          log.printLog("${file.path}");
        }
      } else {
        log.printLog("Коталога не существует");
      }
    } catch (ex) {
      print('Исключение при обновлении: $ex');
    }
  }

  void installUpdate(String path, {bool doExit = false}) async {
    if (path.isEmpty) {
      print('Нет файлов для обновления');
      return;
    }
/*     final bytes = File(path).readAsBytesSync();
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/maggio.apk').create();
    file.writeAsBytesSync(bytes); */

    InstallPlugin.installApk(path, 'com.maggio.maggio_smart').then((result) {
      print('Установка... $result');
    }).catchError((error) {
      print('Ошибка установки обновления: $error');
    });
    // Если можно установить apk без подтверждения - устанавливаем и перезапускаем текущее приложение
    if (doExit) {
      await Future.delayed(const Duration(seconds: 2));
      exit(0);
    }
  }
}

class MainSettings extends StatelessWidget {
  MainSettings({super.key});
  final appc = Get.find<AppController>();
  final MainSettingsController msc = Get.put(MainSettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.colBackground,
        appBar: AppBar(
          leading: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/svg/button_back.svg',
                color: Colors.white,
                width: context.isPhone ? 28 : 36,
              ),
              onPressed: () {
                Get.back();
              }),
          leadingWidth: 70,
          toolbarHeight: context.isPhone ? 56 : 70,
          backgroundColor: AppColors.colTitle,
          centerTitle: true,
          title: Center(
            child: Text(
              'msg_main_settings'.tr,
              style: TextStyle(fontSize: context.isPhone ? 24 : 28, fontFamily: 'Rubik', fontWeight: FontWeight.w300),
            ),
          ),
        ),
        body: Builder(builder: (BuildContext context) {
          return ListView(
            padding: const EdgeInsets.only(left: 20, top: 30, bottom: 30, right: 20),
            children: [
              // Калибровка
              SettingsListItem(
                groupTitle: 'msg_settings_calibr'.tr,
                title: 'msg_settings_calibr_milk'.tr,
                subtitle: 'msg_settings_common'.tr,
                icon: 'assets/icons/svg/settings_calibr.svg',
                iconColor: const Color.fromARGB(255, 116, 243, 184),
                onTap: () {
                  Get.to(() => CalibrateSensor(isMilk: true),
                      duration: const Duration(milliseconds: 500), curve: Curves.ease, transition: Transition.rightToLeft);
                },
              ),
              SettingsListItem(
                title: 'msg_settings_calibr_water'.tr,
                subtitle: 'msg_settings_common'.tr,
                icon: 'assets/icons/svg/settings_calibr.svg',
                iconColor: const Color.fromARGB(255, 116, 243, 184),
                onTap: () {
                  Get.to(() => CalibrateSensor(isMilk: false),
                      duration: const Duration(milliseconds: 500), curve: Curves.ease, transition: Transition.rightToLeft);
                },
              ),
              // Язык
              SettingsListItem(
                groupTitle: 'msg_settings_common'.tr,
                title: 'msg_settings_lang'.tr,
                subtitle: msc.langName.value,
                icon: 'assets/icons/svg/settings_lang.svg',
                iconColor: const Color.fromARGB(255, 155, 79, 255),
                onTap: () {
                  Get.to(() => settingLanguage(), duration: const Duration(milliseconds: 500), curve: Curves.ease, transition: Transition.rightToLeft);
                },
              ),
              // Звуки
              Obx(() => SettingsListItem(
                    title: 'msg_settings_sound'.tr,
                    subtitle: appc.isSoundEnable.value ? 'Включено' : 'Выключено',
                    icon: 'assets/icons/svg/settings_sound.svg',
                    iconColor: const Color.fromARGB(255, 226, 104, 226),
                    //content: soundOnOff(),
                    onTap: () {
                      Get.to(() => settingSound(), duration: const Duration(milliseconds: 500), curve: Curves.ease, transition: Transition.rightToLeft);
                    },
                  )),
              // Bluetooth
              Obx(() => SettingsListItem(
                    title: 'msg_settings_bluetooth'.tr,
                    subtitle: "Состояние: ${appc.blu.bluetoothState.value}\nУстройство: ${appc.blu.deviceName.value} (${appc.blu.deviceAddress.value})",
                    icon: 'assets/icons/svg/settings_bluetooth.svg',
                    iconColor: const Color.fromARGB(255, 83, 117, 230),
                    content: btConnect(context),
                  )),
              // Общие настройки
              SettingsListItem(
                title: 'msg_settings_system'.tr,
                //subtitle: 'msg_settings_common'.tr,
                icon: 'assets/icons/svg/settings_system.svg',
                iconColor: const Color.fromARGB(255, 110, 132, 163),
                onTap: () async {
                  SystemSettings.system();
                },
              ),
              // О программе
              Obx(() => SettingsListItem(
                    title: 'msg_settings_about'.tr,
                    subtitle: "${'msg_settings_update_current_ver'.tr}: ${msc.appCurrentInfo['version']} (${msc.appCurrentInfo['buildNumber']})",
                    icon: 'assets/icons/svg/settings_info.svg',
                    iconColor: const Color.fromARGB(255, 241, 168, 168),
                    onTap: () {
                      Get.to(() => settingAbout(), duration: const Duration(milliseconds: 500), curve: Curves.ease, transition: Transition.rightToLeft);
                    },
                  )),
            ],
          );
        }));
  }
}

// Обновление приложения
/*
  Widget updateSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'msg_settings_update'.tr,
          style: TextStyle(fontSize: context.isPhone ? 20 : 26, color: AppColors.colWhite),
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        const SizedBox(height: 40),
        _updateContentWidget(context),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () async {
                await msc.upd.checkOTAUpdate(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colNagrev,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('msg_button_update'.tr, style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontFamily: 'Rubik', color: AppColors.colDark)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _updateContentWidget(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "${'msg_settings_update_current_ver'.tr}:",
            style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colDarkGrey),
          ),
          const SizedBox(width: 20),
          Obx(() => Text(
                "${msc.upd.appCurrentVersion}",
                style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colWhite),
              )),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "${'msg_settings_update_new_ver'.tr}:",
            style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colDarkGrey),
          ),
          const SizedBox(width: 20),
          Obx(() => Text(
                "${msc.upd.appNewVersion}",
                style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colCurrNagrev),
              )),
        ],
      ),
    ]);
  }
*/

// Калибровка датчиков
class CalibrateSensor extends StatelessWidget {
  CalibrateSensor({super.key, this.isMilk = true});
  final bool isMilk;

  final appc = Get.find<AppController>();
  final MainSettingsController msc = Get.find<MainSettingsController>();

  @override
  Widget build(BuildContext context) {
    msc._context_unfocus = context;
    return GestureDetector(
        onTap: () => {
              if (msc._focusNodeHI.hasFocus || msc._focusNodeLO.hasFocus) {msc._unFocus(context)}
            },
        child: Scaffold(
            backgroundColor: AppColors.colBackground,
            appBar: AppBar(
              leading: IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/svg/button_back.svg',
                    color: Colors.white,
                    width: context.isPhone ? 28 : 36,
                  ),
                  onPressed: () {
                    //Get.offUntil((route) => Get.currentRoute == '/mainsettings');
                    //Get.off(() => MainSettings());
                    Get.back();
                  }),
              leadingWidth: 70,
              toolbarHeight: context.isPhone ? 56 : 70,
              backgroundColor: AppColors.colTitle,
              centerTitle: true,
              title: Center(
                child: Text(
                  isMilk ? 'msg_settings_calibr_milk'.tr : 'msg_settings_calibr_water'.tr,
                  style: TextStyle(fontSize: context.isPhone ? 24 : 28, fontFamily: 'Rubik', fontWeight: FontWeight.w300),
                ),
              ),
            ),
            body: Builder(builder: (BuildContext context) {
              msc._context = context;
              return SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 20, top: 30, bottom: 30, right: 20),
                      child: Form(
                          key: msc._formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            // Текущее значение
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "${'msg_settings_calibr_current'.tr}:",
                                  style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colDarkGrey),
                                ),
                                const SizedBox(width: 20),
                                Obx(() => Text(
                                      isMilk ? "${appc.currentTempMilk} ${'msg_grad'.tr}" : "${appc.currentTempWater} ${'msg_grad'.tr}",
                                      style: TextStyle(fontSize: context.isPhone ? 22 : 28, color: AppColors.colNagrev),
                                    )),
                              ],
                            ),

                            const SizedBox(height: 30),
                            Obx(() => Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Focus(
                                            onFocusChange: (hasFocus) {
                                              if (hasFocus) {
                                                msc.focusHI.value = true;
                                                msc.focusLO.value = false;
                                              } else {
                                                msc.focusHI.value = false;
                                              }
                                            },
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  msc._textFieldErrorHI.value = false;
                                                  msc.disableBtnHI.value = true;
                                                  return null;
                                                } else if (value != null && msc._isError(msc._textControllerHI.text)) {
                                                  msc._textFieldErrorHI.value = true;
                                                  return 'msg_notify_temp_error'.tr;
                                                } else {
                                                  msc._textFieldErrorHI.value = false;
                                                  msc.disableBtnHI.value = false;
                                                  return null;
                                                }
                                              },
                                              controller: msc._textControllerHI,
                                              focusNode: msc._focusNodeHI,
                                              showCursor: true,
                                              readOnly: true,
                                              //keyboardType: TextInputType.phone,
                                              style: TextStyle(color: Colors.white, fontSize: context.isPhone ? 18 : 22),
                                              decoration: InputDecoration(
                                                labelText: 'msg_settings_calibr_hight'.tr,
                                                labelStyle: TextStyle(color: AppColors.colDarkGrey, fontSize: context.isPhone ? 18 : 22),
                                                floatingLabelStyle: TextStyle(
                                                    color: msc._textFieldErrorHI.value
                                                        ? AppColors.colButtonStart
                                                        : msc.focusHI.value
                                                            ? AppColors.colNagrev
                                                            : AppColors.colWhite),
                                                filled: true,
                                                fillColor: AppColors.colDarkGrey4,
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: context.isPhone ? 20 : 30),
                                                enabledBorder: OutlineInputBorder(
                                                  gapPadding: 10.0,
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: const BorderSide(color: AppColors.colWhite, width: 1.5),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  gapPadding: 10.0,
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: const BorderSide(color: AppColors.colNagrev, width: 1.5),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                    gapPadding: 10.0,
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: const BorderSide(color: AppColors.colButtonStart, width: 1.5)),
                                                focusedErrorBorder: OutlineInputBorder(
                                                    gapPadding: 10.0,
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: const BorderSide(color: AppColors.colButtonStart, width: 1.5)),
                                                errorStyle: const TextStyle(color: AppColors.colButtonStart),
                                              ),
                                            ))),
                                    const SizedBox(width: 20),
                                    ElevatedButton(
                                      onPressed: msc._textFieldErrorHI.value || msc.disableBtnHI.value
                                          ? null
                                          : () => isMilk
                                              ? appc.calibrateSensor("S1", msc._textControllerHI.text)
                                              : appc.calibrateSensor("S3", msc._textControllerHI.text),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.colNagrev,
                                        disabledBackgroundColor: AppColors.colDarkGrey2,
                                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: context.isPhone ? 20 : 30),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text('msg_button_calibr'.tr,
                                          style: TextStyle(fontSize: context.isPhone ? 15 : 20, fontFamily: 'Rubik', color: AppColors.colDark)),
                                    ),
                                  ],
                                )),

                            const SizedBox(height: 50),
                            Obx(() => Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Focus(
                                            onFocusChange: (hasFocus) {
                                              if (hasFocus) {
                                                msc.focusLO.value = true;
                                                msc.focusHI.value = false;
                                              } else {
                                                msc.focusLO.value = false;
                                              }
                                            },
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  msc._textFieldErrorLO.value = false;
                                                  msc.disableBtnLO.value = true;
                                                  return null;
                                                } else if (value != null && msc._isError(msc._textControllerLO.text)) {
                                                  msc._textFieldErrorLO.value = true;
                                                  return 'msg_notify_temp_error'.tr;
                                                } else {
                                                  msc._textFieldErrorLO.value = false;
                                                  msc.disableBtnLO.value = false;
                                                  return null;
                                                }
                                              },
                                              controller: msc._textControllerLO,
                                              focusNode: msc._focusNodeLO,
                                              showCursor: true,
                                              readOnly: true,
                                              //keyboardType: TextInputType.phone,
                                              style: TextStyle(color: Colors.white, fontSize: context.isPhone ? 18 : 22),
                                              decoration: InputDecoration(
                                                labelText: 'msg_settings_calibr_low'.tr,
                                                labelStyle: TextStyle(color: AppColors.colDarkGrey, fontSize: context.isPhone ? 18 : 22),
                                                floatingLabelStyle: TextStyle(
                                                    color: msc._textFieldErrorLO.value
                                                        ? AppColors.colButtonStart
                                                        : msc.focusLO.value
                                                            ? AppColors.colNagrev
                                                            : AppColors.colWhite),
                                                filled: true,
                                                fillColor: AppColors.colDarkGrey4,
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: context.isPhone ? 20 : 30),
                                                enabledBorder: OutlineInputBorder(
                                                  gapPadding: 10.0,
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: const BorderSide(color: AppColors.colWhite, width: 1.5),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  gapPadding: 10.0,
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: const BorderSide(color: AppColors.colNagrev, width: 1.5),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                    gapPadding: 10.0,
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: const BorderSide(color: AppColors.colButtonStart, width: 1.5)),
                                                focusedErrorBorder: OutlineInputBorder(
                                                    gapPadding: 10.0,
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: const BorderSide(color: AppColors.colButtonStart, width: 1.5)),
                                                errorStyle: const TextStyle(color: AppColors.colButtonStart),
                                              ),
                                            ))),
                                    const SizedBox(width: 20),
                                    ElevatedButton(
                                      onPressed: msc._textFieldErrorLO.value || msc.disableBtnLO.value
                                          ? null
                                          : () => isMilk
                                              ? appc.calibrateSensor("S2", msc._textControllerLO.text)
                                              : appc.calibrateSensor("S4", msc._textControllerLO.text),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.colNagrev,
                                        disabledBackgroundColor: AppColors.colDarkGrey2,
                                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: context.isPhone ? 20 : 30),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text('msg_button_calibr'.tr,
                                          style: TextStyle(fontSize: context.isPhone ? 15 : 20, fontFamily: 'Rubik', color: AppColors.colDark)),
                                    ),
                                  ],
                                )),
                            const SizedBox(height: 40),

                            // Сбросить настройки
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      appc.resetSensor(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.white, width: 2),
                                      padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: Text('msg_button_reset'.tr,
                                        style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontFamily: 'Rubik', color: Colors.white)),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 50),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/svg/settings_info.svg',
                                  color: Colors.white,
                                  width: context.isPhone ? 20 : 24,
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                    child: RichText(
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.fade,
                                  text: TextSpan(children: <TextSpan>[
                                    TextSpan(
                                        text: "Для калибровки датчиков молока и воды необходимо иметь эталонный прибор для измерения температуры.\n\n",
                                        style: TextStyle(fontSize: context.isPhone ? 14 : 16, color: AppColors.colDarkGrey)),
                                    TextSpan(
                                        text: "Для того, чтобы откалибровать ",
                                        style: TextStyle(fontSize: context.isPhone ? 14 : 16, color: AppColors.colDarkGrey)),
                                    TextSpan(
                                        text: "нижнюю",
                                        style: TextStyle(fontSize: context.isPhone ? 14 : 16, fontWeight: FontWeight.w500, color: AppColors.colWhite)),
                                    TextSpan(
                                        text:
                                            " границу датчика, воспользуйтесь эталонным термометром и при комнатной темперетуре сравните показания эталонного термометра и датчика. Если они значительно отличаются, то укажите эталонную температуру и нажмите кнопку \"КАЛИБРОВАТЬ\".\n\n",
                                        style: TextStyle(fontSize: context.isPhone ? 14 : 16, color: AppColors.colDarkGrey)),
                                    TextSpan(
                                        text: "Для того, чтобы откалибровать ",
                                        style: TextStyle(fontSize: context.isPhone ? 14 : 16, color: AppColors.colDarkGrey)),
                                    TextSpan(
                                        text: "верхнюю",
                                        style: TextStyle(fontSize: context.isPhone ? 14 : 16, fontWeight: FontWeight.w500, color: AppColors.colWhite)),
                                    TextSpan(
                                        text:
                                            " границу датчика, поместите датчик и эталонный термометр, например, в кипящую воду и сравните показания температур. Если они значительно отличаются, то укажите эталонную температуру и нажмите кнопку \"КАЛИБРОВАТЬ\".\n\n",
                                        style: TextStyle(fontSize: context.isPhone ? 14 : 16, color: AppColors.colDarkGrey)),
                                    TextSpan(
                                        text: "Для установки настроек калибровки по умолчанию, нажмите кнопку \"СБРОСИТЬ НАСТРОЙКИ\".",
                                        style: TextStyle(fontSize: context.isPhone ? 14 : 16, color: AppColors.colDarkGrey)),
                                  ]),
                                )),
                              ],
                            )
                          ]))));
            })));
  }
}

// Настройка языка
class settingLanguage extends StatelessWidget {
  final appc = Get.find<AppController>();
  final MainSettingsController msc = Get.find<MainSettingsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.colBackground,
        appBar: AppBar(
          leading: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/svg/button_back.svg',
                color: Colors.white,
                width: context.isPhone ? 28 : 36,
              ),
              onPressed: () {
                Get.back();
              }),
          leadingWidth: 70,
          toolbarHeight: context.isPhone ? 56 : 70,
          backgroundColor: AppColors.colTitle,
          centerTitle: true,
          title: Center(
            child: Text(
              'msg_settings_lang'.tr,
              style: TextStyle(fontSize: context.isPhone ? 24 : 28, fontFamily: 'Rubik', fontWeight: FontWeight.w300),
            ),
          ),
        ),
        body: Builder(builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.only(left: 20, top: 30, bottom: 30, right: 20),
            child: Obx(() => SelectButton(
                text: 'msg_settings_lang_select'.tr,
                activeColor: const Color.fromARGB(255, 118, 94, 255),
                inActiveColor: AppColors.colLightGrey,
                list: msc.langs,
                value: appc.currentLang.value,
                onChanged: (value) {
                  msc._onLangChange(value);
                })),
          );
        }));
  }
}

// Настройка громкости
class settingSound extends StatelessWidget {
  final appc = Get.find<AppController>();
  final MainSettingsController msc = Get.find<MainSettingsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.colBackground,
        appBar: AppBar(
          leading: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/svg/button_back.svg',
                color: Colors.white,
                width: context.isPhone ? 28 : 36,
              ),
              onPressed: () {
                Get.back();
              }),
          leadingWidth: 70,
          toolbarHeight: context.isPhone ? 56 : 70,
          backgroundColor: AppColors.colTitle,
          centerTitle: true,
          title: Center(
            child: Text(
              'msg_settings_sound'.tr,
              style: TextStyle(fontSize: context.isPhone ? 24 : 28, fontFamily: 'Rubik', fontWeight: FontWeight.w300),
            ),
          ),
        ),
        body: Builder(builder: (BuildContext context) {
          return Padding(
              padding: const EdgeInsets.only(left: 20, top: 30, bottom: 30, right: 20),
              child: Column(children: [
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text(('msg_settings_sound'.tr + ', ' + 'msg_settings_sound_help'.tr).toUpperCase(),
                      style: TextStyle(
                        fontSize: context.isPhone ? 15 : 18,
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w300,
                        color: AppColors.colLightGrey,
                      )),
                  const SizedBox(width: 40),
                  Transform.scale(
                      scale: context.isPhone ? 1.2 : 1.7,
                      child: Obx(
                        () => Switch.adaptive(
                          value: appc.isSoundEnable.value,
                          onChanged: (value) {
                            appc.isSoundEnable.value = value;
                          },
                          activeColor: AppColors.colWhite,
                          activeTrackColor: AppColors.colViderzhka,
                          inactiveTrackColor: AppColors.colDarkGrey2,
                          inactiveThumbColor: AppColors.colDarkGrey,
                          splashRadius: 20,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      )),
                ]),
                const SizedBox(height: 20),
                CustomSlider(
                    text: 'msg_settings_sound_volume'.tr,
                    label: ' %',
                    activeColor: AppColors.colViderzhka,
                    min: 0,
                    max: 100,
                    //divisions: 9,
                    value: appc.currentVolume.value.toDouble(),
                    onChanged: (value) {
                      appc.currentVolume.value = value.truncate();
                      VolumeController().setVolume(value / 100);
                    }),
              ]));
        }));
  }
}

// Настройка языка
class settingAbout extends StatelessWidget {
  final appc = Get.find<AppController>();
  final MainSettingsController msc = Get.find<MainSettingsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.colBackground,
        appBar: AppBar(
          leading: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/svg/button_back.svg',
                color: Colors.white,
                width: context.isPhone ? 28 : 36,
              ),
              onPressed: () {
                Get.back();
              }),
          leadingWidth: 70,
          toolbarHeight: context.isPhone ? 56 : 70,
          backgroundColor: AppColors.colTitle,
          centerTitle: true,
          title: Center(
            child: Text(
              'msg_settings_about'.tr,
              style: TextStyle(fontSize: context.isPhone ? 24 : 28, fontFamily: 'Rubik', fontWeight: FontWeight.w300),
            ),
          ),
        ),
        body: Builder(builder: (BuildContext context) {
          return Padding(padding: EdgeInsets.only(left: 20, top: 30, bottom: 30, right: 20), child: null
/*             Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    msc.checkForUpdates();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("ПРОВЕРИТЬ Обновку", style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontFamily: 'Rubik', color: Colors.white)),
                ),
                const SizedBox(
                  width: 30,
                ),
                OutlinedButton(
                  onPressed: () {
                    msc.installUpdate(msc.updatePath);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("УСТАНОВИТЬ Обновку", style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontFamily: 'Rubik', color: Colors.white)),
                ),
              ],
            ), */
              );
        }));
  }
}

// Переключатель Bluetooth
Widget btConnect(BuildContext context) {
  final appc = Get.find<AppController>();

  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Obx(() => appc.blu.isDiscovering.value
        ? const SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ))
        : const SizedBox()),
    const SizedBox(width: 20),
    Transform.scale(
      scale: context.isPhone ? 1.2 : 1.7,
      child: Obx(() => Switch.adaptive(
            value: appc.blu.isSelectBlue.value,
            onChanged: (value) {
              appc.blu.toogleBTonDevice(value);
            },
            activeColor: AppColors.colWhite,
            activeTrackColor: AppColors.colViderzhka,
            inactiveTrackColor: AppColors.colDarkGrey2,
            inactiveThumbColor: AppColors.colDarkGrey,
            splashRadius: 20,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )),
    ),
  ]);
}

class SettingsListItem extends StatelessWidget {
  final VoidCallback? onTap;
  final String? groupTitle;
  final String? title;
  final String? subtitle;
  final String? icon;
  final Widget? content;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;

  const SettingsListItem({
    Key? key,
    this.groupTitle,
    this.title,
    this.subtitle,
    this.icon,
    this.content,
    this.iconColor = Colors.white,
    this.titleColor = AppColors.colWhite,
    this.subtitleColor = AppColors.colDarkGrey,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (groupTitle != null)
        Padding(
            padding: context.isPhone ? const EdgeInsets.only(top: 20, bottom: 12) : const EdgeInsets.only(top: 30, bottom: 15),
            child: Text(
              groupTitle ?? '',
              style: TextStyle(fontFamily: 'Rubik', fontSize: context.isPhone ? 18 : 26, color: AppColors.colWhite),
            )),
      Container(
          margin: const EdgeInsets.only(bottom: 10),
          clipBehavior: Clip.hardEdge,
          constraints: const BoxConstraints(minHeight: 62),
          decoration: BoxDecoration(color: AppColors.colDarkGrey4, borderRadius: BorderRadius.circular(10)),
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  splashColor: const Color.fromARGB(10, 255, 255, 255),
                  overlayColor: MaterialStateProperty.all(const Color.fromARGB(10, 255, 255, 255)),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (icon != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: SvgPicture.asset(
                              icon ?? '',
                              color: iconColor,
                              width: context.isPhone ? 22 : 40,
                              height: context.isPhone ? 22 : 40,
                            ),
                          ),

                        Expanded(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null) Text(title ?? '', style: TextStyle(fontFamily: 'Rubik', fontSize: context.isPhone ? 18 : 22, color: titleColor)),
                            if (subtitle != null)
                              Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child:
                                      Text(subtitle ?? '', style: TextStyle(fontFamily: 'Rubik', fontSize: context.isPhone ? 14 : 18, color: subtitleColor))),
                          ],
                        )),

                        if (content != null) Padding(padding: const EdgeInsets.only(left: 20), child: content),

                        // СТРЕЛКА
                        if (onTap != null)
                          SvgPicture.asset(
                            'assets/icons/svg/button_arrow.svg',
                            color: Colors.white,
                            width: context.isPhone ? 12 : 14,
                          ),
                      ],
                    ),
                  ))))
    ]);
  }
}
