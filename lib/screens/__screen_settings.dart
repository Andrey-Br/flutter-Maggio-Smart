import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:system_settings/system_settings.dart';
import '../controllers/appcontroller.dart';
//import '../services/update_service.dart';
import '../widgets/select_btn.dart';
import '../widgets/keyboard.dart';
import '../variables/colors.dart';

class MainSettingsController extends GetxController {
  var langName = 'msg_settings_lang_ru'.tr.obs;
  final langs = [
    'msg_settings_lang_ru'.tr,
    'msg_settings_lang_en'.tr,
  ];

  var calibrHIValue = "".obs;
  var calibrLOValue = "".obs;
  late BuildContext _context;
  late BuildContext _main_context;

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

  //final UpdateService upd = Get.put(UpdateService());

  @override
  void onInit() {
    super.onInit();
    _focusNodeHI.addListener(_onFocusChange);
    _focusNodeLO.addListener(_onFocusChange);
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
    super.onClose();
  }

  void _unFocus(BuildContext context) {
    try {
      FocusScope.of(context).unfocus();
      if (_focusNodeHI.hasFocus || _focusNodeLO.hasFocus) {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Ошибка закрытия: $e");
    }
  }

  void _onFocusChange() {
    if (_focusNodeHI.hasFocus || _focusNodeLO.hasFocus) {
      showBottomSheet(
        context: _context,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (context) => VirtualKeyboard(height: 150, fontSize: 28, textColor: Colors.white, type: VirtualKeyboardType.Numeric, onKeyPress: _onKeyPress),
      );
    } else {
      //Navigator.pop(_context);
    }
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
}

class MainSettings extends StatelessWidget {
  MainSettings({super.key});
  final appc = Get.find<AppController>();
  //final MainSettingsController msc = Get.put(MainSettingsController());

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
                //Get.back();
                Navigator.pop(appc.appContext);
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
                //subtitle: msc.langName.value,
                icon: 'assets/icons/svg/settings_lang.svg',
                iconColor: const Color.fromARGB(255, 155, 79, 255),
                onTap: () {
                  Get.to(() => settingLanguage(), duration: const Duration(milliseconds: 500), curve: Curves.ease, transition: Transition.rightToLeft);
                },
              ),
              // Звуки
              Obx(() => SettingsListItem(
                    title: 'msg_settings_sound_help'.tr,
                    subtitle: appc.isSoundEnable.value ? 'Включено' : 'Выключено',
                    icon: 'assets/icons/svg/settings_sound.svg',
                    iconColor: const Color.fromARGB(255, 226, 104, 226),
                    content: soundOnOff(),
                  )),
              // Bluetooth
              Obx(() => SettingsListItem(
                    title: 'msg_settings_bluetooth'.tr,
                    subtitle: "Состояние: ${appc.blu.bluetoothState.value}\nУстройство: ${appc.blu.deviceName.value} (${appc.blu.deviceAddress.value})",
                    icon: 'assets/icons/svg/settings_bluetooth.svg',
                    iconColor: const Color.fromARGB(255, 83, 117, 230),
                    content: btConnect(),
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
              SettingsListItem(
                title: 'msg_settings_about'.tr,
                subtitle: 'msg_settings_update'.tr,
                icon: 'assets/icons/svg/settings_info.svg',
                iconColor: const Color.fromARGB(255, 241, 168, 168),
                onTap: () {
                  Get.to(() => settingAbout(), duration: const Duration(milliseconds: 500), curve: Curves.ease, transition: Transition.rightToLeft);
                },
              ),
            ],
          );
        }));
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

}

// Калибровка датчиков
class CalibrateSensor extends StatelessWidget {
  CalibrateSensor({super.key, this.isMilk = true});
  final bool isMilk;

  final appc = Get.find<AppController>();
  //final MainSettingsController msc = Get.put(MainSettingsController());
  late BuildContext _context;
  final calibrHIValue = "".obs;
  final calibrLOValue = "".obs;
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

  //@override
  void initState() {
    //super.initState();
    _focusNodeHI.addListener(_onFocusChange);
    _focusNodeLO.addListener(_onFocusChange);
    print("OnInit");
  }

  //@override
  void dispose() {
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
    print("OnClose");
    //super.dispose();
  }

  void _unFocus(BuildContext context) {
    try {
      FocusScope.of(context).unfocus();
      if (_focusNodeHI.hasFocus || _focusNodeLO.hasFocus) {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Ошибка закрытия: $e");
    }
  }

  void _onFocusChange() {
    if (_focusNodeHI.hasFocus || _focusNodeLO.hasFocus) {
      showBottomSheet(
        context: _context,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (context) => VirtualKeyboard(height: 150, fontSize: 28, textColor: Colors.white, type: VirtualKeyboardType.Numeric, onKeyPress: _onKeyPress),
      );
    } else {
      //Navigator.pop(_context);
    }
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
          default:
        }
      }
      _textControllerLO.text = calibrLOValue.value.toString();
      _textControllerLO.selection = TextSelection.collapsed(offset: _textControllerLO.text.length);
    }
  }

  _isError(String val) {
    var t = 0.0;
    try {
      val.isNotEmpty && val != '.' ? t = (num.parse(val) * 10).round() / 10 : t = 0;
    } catch (_) {}
    return (t <= 0 || t > 100) ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return GestureDetector(
        onTap: () => {
              if (_focusNodeHI.hasFocus || _focusNodeLO.hasFocus) {_unFocus(context)}
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
                    Get.back(closeOverlays: true);
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
              print("CONTEXT:  $context");

              return SingleChildScrollView(
                  reverse: true,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 20, top: 30, bottom: 30, right: 20),
                      child: Column(children: [
                        Form(
                            key: _formKey,
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
                                                  focusHI.value = true;
                                                  focusLO.value = false;
                                                } else {
                                                  focusHI.value = false;
                                                }
                                              },
                                              child: TextFormField(
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    _textFieldErrorHI.value = false;
                                                    disableBtnHI.value = true;
                                                    return null;
                                                  } else if (value != null && _isError(_textControllerHI.text)) {
                                                    _textFieldErrorHI.value = true;
                                                    return 'msg_notify_temp_error'.tr;
                                                  } else {
                                                    _textFieldErrorHI.value = false;
                                                    disableBtnHI.value = false;
                                                    return null;
                                                  }
                                                },
                                                controller: _textControllerHI,
                                                focusNode: _focusNodeHI,
                                                showCursor: true,
                                                //readOnly: true,
                                                keyboardType: TextInputType.number,
                                                style: TextStyle(color: Colors.white, fontSize: context.isPhone ? 18 : 22),
                                                decoration: InputDecoration(
                                                  labelText: 'msg_settings_calibr_hight'.tr,
                                                  labelStyle: TextStyle(color: AppColors.colDarkGrey, fontSize: context.isPhone ? 18 : 22),
                                                  floatingLabelStyle: TextStyle(
                                                      color: _textFieldErrorHI.value
                                                          ? AppColors.colButtonStart
                                                          : focusHI.value
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
                                        onPressed: _textFieldErrorHI.value || disableBtnHI.value
                                            ? null
                                            : () => isMilk
                                                ? appc.calibrateSensor("S1", _textControllerHI.text)
                                                : appc.calibrateSensor("S3", _textControllerHI.text),
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
                                                  focusLO.value = true;
                                                  focusHI.value = false;
                                                } else {
                                                  focusLO.value = false;
                                                }
                                              },
                                              child: TextFormField(
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    _textFieldErrorLO.value = false;
                                                    disableBtnLO.value = true;
                                                    return null;
                                                  } else if (value != null && _isError(_textControllerLO.text)) {
                                                    _textFieldErrorLO.value = true;
                                                    return 'msg_notify_temp_error'.tr;
                                                  } else {
                                                    _textFieldErrorLO.value = false;
                                                    disableBtnLO.value = false;
                                                    return null;
                                                  }
                                                },
                                                controller: _textControllerLO,
                                                focusNode: _focusNodeLO,
                                                showCursor: true,
                                                readOnly: true,
                                                //keyboardType: TextInputType.phone,
                                                style: TextStyle(color: Colors.white, fontSize: context.isPhone ? 18 : 22),
                                                decoration: InputDecoration(
                                                  labelText: 'msg_settings_calibr_low'.tr,
                                                  labelStyle: TextStyle(color: AppColors.colDarkGrey, fontSize: context.isPhone ? 18 : 22),
                                                  floatingLabelStyle: TextStyle(
                                                      color: _textFieldErrorLO.value
                                                          ? AppColors.colButtonStart
                                                          : focusLO.value
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
                                        onPressed: _textFieldErrorLO.value || disableBtnLO.value
                                            ? null
                                            : () => isMilk
                                                ? appc.calibrateSensor("S2", _textControllerLO.text)
                                                : appc.calibrateSensor("S4", _textControllerLO.text),
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
                            ])),
                        Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                        )
                      ])));
            })));
  }
}

// Настройка языка
class settingLanguage extends StatelessWidget {
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
                Get.back(closeOverlays: true);
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

// Настройка языка
class settingAbout extends StatelessWidget {
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
                Get.back(closeOverlays: true);
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
          return Padding(padding: const EdgeInsets.only(left: 20, top: 30, bottom: 30, right: 20), child: null);
        }));
  }
}

// Переключатель Bluetooth
Widget btConnect() {
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
      scale: 1.7,
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

// Переключатель Звуков
Widget soundOnOff() {
  final appc = Get.find<AppController>();

  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Transform.scale(
      scale: 1.7,
      child: Obx(() => Switch.adaptive(
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
          constraints: const BoxConstraints(minHeight: 80),
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

void showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.colBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      contentPadding: EdgeInsets.all(context.isPhone ? 10 : 20),
      content: Builder(
        builder: (context) {
          return Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/svg/button_delete.svg',
                      color: Colors.white,
                      width: context.isPhone ? 24 : 30,
                    ),
                    onPressed: () {
                      Get.back();
                    }),
              ]),
              Expanded(
                  child: SingleChildScrollView(
                      child: Container(
                width: 500,
                padding: EdgeInsets.all(context.isPhone ? 7 : 15),
                child: RichText(
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.fade,
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: "Для калибровки датчиков молока и воды необходимо иметь эталонный прибор для измерения температуры.\n\n\n",
                        style: TextStyle(fontSize: context.isPhone ? 20 : 26, color: AppColors.colWhite)),
                    TextSpan(text: "Для того, чтобы откалибровать ", style: TextStyle(fontSize: context.isPhone ? 16 : 20, color: AppColors.colWhite)),
                    TextSpan(
                        text: "нижнюю",
                        style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 37, 228, 253))),
                    TextSpan(
                        text:
                            " границу датчика, воспользуйтесь эталонным термометром и при комнатной темперетуре сравните показания эталонного термометра и датчика. Если они значительно отличаются, то укажите эталонную температуру и нажмите кнопку \"КАЛИБРОВАТЬ\".\n\n",
                        style: TextStyle(fontSize: context.isPhone ? 16 : 20, color: AppColors.colWhite)),
                    TextSpan(text: "Для того, чтобы откалибровать ", style: TextStyle(fontSize: context.isPhone ? 16 : 20, color: AppColors.colWhite)),
                    TextSpan(
                        text: "верхнюю",
                        style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 253, 159, 37))),
                    TextSpan(
                        text:
                            " границу датчика, поместите датчик и эталонный термометр, например, в кипящую воду и сравните показания температур. Если они значительно отличаются, то укажите эталонную температуру и нажмите кнопку \"КАЛИБРОВАТЬ\".\n\n",
                        style: TextStyle(fontSize: context.isPhone ? 16 : 20, color: AppColors.colWhite)),
                    TextSpan(
                        text: "Для установки настроек калибровки по умолчанию, нажмите кнопку \"СБРОСИТЬ НАСТРОЙКИ\".",
                        style: TextStyle(fontSize: context.isPhone ? 16 : 20, color: AppColors.colWhite)),
                  ]),
                ),
              ))),
            ],
          );
        },
      ),
    ),
  );
}
