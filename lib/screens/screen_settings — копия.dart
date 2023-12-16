import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:system_settings/system_settings.dart';
import '../controllers/appcontroller.dart';
//import '../services/update_service.dart';
import '../widgets/keyboard.dart';
import '../variables/colors.dart';

class MainSettingsController extends GetxController {
  var lang = 'msg_settings_lang_ru'.tr.obs;

  final langs = [
    'msg_settings_lang_ru'.tr,
    'msg_settings_lang_en'.tr,
  ];

  var calibrMilkValue = "".obs;
  var calibrWaterValue = "".obs;
  late BuildContext _context;
  final FocusNode _focusNodeMLK = FocusNode();
  final FocusNode _focusNodeWTR = FocusNode();
  final TextEditingController _textControllerMLK = TextEditingController();
  final TextEditingController _textControllerWTR = TextEditingController();

  //final UpdateService upd = Get.put(UpdateService());

  @override
  void onInit() {
    super.onInit();
    _focusNodeMLK.addListener(_onFocusChange);
    _focusNodeWTR.addListener(_onFocusChange);
  }

  @override
  void onClose() {
    _textControllerMLK.clear();
    _textControllerWTR.clear();
    _textControllerMLK.dispose();
    _textControllerWTR.dispose();
    calibrMilkValue.value = '';
    calibrWaterValue.value = '';
    _focusNodeMLK.removeListener(_onFocusChange);
    _focusNodeWTR.removeListener(_onFocusChange);
    _focusNodeMLK.dispose();
    _focusNodeWTR.dispose();
    super.onClose();
  }

  void _unFocus(BuildContext context) {
    try {
      FocusScope.of(context).unfocus();
      if (_focusNodeMLK.hasFocus || _focusNodeWTR.hasFocus) {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Ошибка закрытия: $e");
    }
  }

  void _onFocusChange() {
    if (_focusNodeMLK.hasFocus || _focusNodeWTR.hasFocus) {
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
    if (_focusNodeMLK.hasFocus) {
      if (key.keyType == VirtualKeyboardKeyType.String) {
        calibrMilkValue.value = calibrMilkValue.value + key.text;
      } else if (key.keyType == VirtualKeyboardKeyType.Action) {
        switch (key.action) {
          case VirtualKeyboardKeyAction.Backspace:
            if (calibrMilkValue.value.isEmpty) return;
            calibrMilkValue.value = calibrMilkValue.value.substring(0, calibrMilkValue.value.length - 1);
            break;
          default:
        }
      }
      _textControllerMLK.text = calibrMilkValue.value.toString();
      _textControllerMLK.selection = TextSelection.collapsed(offset: _textControllerMLK.text.length);
    } else if (_focusNodeWTR.hasFocus) {
      if (key.keyType == VirtualKeyboardKeyType.String) {
        calibrWaterValue.value = calibrWaterValue.value + key.text;
      } else if (key.keyType == VirtualKeyboardKeyType.Action) {
        switch (key.action) {
          case VirtualKeyboardKeyAction.Backspace:
            if (calibrWaterValue.value.isEmpty) return;
            calibrWaterValue.value = calibrWaterValue.value.substring(0, calibrWaterValue.value.length - 1);
            break;
          default:
        }
      }
      _textControllerWTR.text = calibrWaterValue.value.toString();
      _textControllerWTR.selection = TextSelection.collapsed(offset: _textControllerWTR.text.length);
    }
  }

  void _onLangChange(val) {
    if (val == 'msg_settings_lang_ru'.tr) {
      var locale = const Locale('ru', 'RU');
      Get.updateLocale(locale);
    } else if (val == 'msg_settings_lang_en'.tr) {
      var locale = const Locale('en', 'US');
      Get.updateLocale(locale);
    }

    lang.value = val;
  }
}

class MainSettings extends StatelessWidget {
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
          msc._context = context;
          return GestureDetector(
              onTap: () => {
                    if (msc._focusNodeMLK.hasFocus || msc._focusNodeWTR.hasFocus) {msc._unFocus(context)}
                  },
              child: DefaultTextStyle(
                style: TextStyle(
                    fontSize: context.isPhone ? 18 : 24,
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w300,
                    decoration: TextDecoration.none,
                    color: Colors.white),
                child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, top: 30, bottom: 30, right: 20),
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Stack(
                            children: [
                              Flex(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                direction: context.isLandscape ? Axis.horizontal : Axis.vertical,
                                children: [
                                  calibrateMilk(context),
                                  context.isLandscape ? const SizedBox(width: 20) : const SizedBox(height: 40),
                                  calibrateWater(context),
                                ],
                              ),
                              Positioned(
                                right: context.isPhone ? -10 : 0,
                                top: -12,
                                child: IconButton(
                                    icon: SvgPicture.asset(
                                      'assets/icons/svg/button_question.svg',
                                      color: Colors.white,
                                    ),
                                    iconSize: context.isPhone ? 30 : 40,
                                    onPressed: () {
                                      showHelpDialog(context);
                                    }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          // Сбросить настройки
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: OutlinedButton(
                                  onPressed: () {
                                    //appc.resetSensor();
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
                          const SizedBox(height: 60),
                          Flex(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            direction: context.isLandscape ? Axis.horizontal : Axis.vertical,
                            children: [
                              commonSettings(context),
                              //context.isLandscape ? const SizedBox(width: 20) : const SizedBox(height: 40),
                              //updateSettings(context),
                            ],
                          ),
                        ],
                      ),
                    )),
              ));
        }));
  }

// Калибровка датчика молока
  Widget calibrateMilk(BuildContext context) {
    return Flexible(
        flex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'msg_settings_calibr_milk'.tr,
              style: TextStyle(fontSize: context.isPhone ? 20 : 26, color: AppColors.colWhite),
              overflow: TextOverflow.fade,
              softWrap: false,
              maxLines: 1,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${'msg_settings_calibr_current'.tr}:",
                  style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colDarkGrey),
                ),
                const SizedBox(width: 20),
                Obx(() => Text(
                      "${appc.currentTempMilk} ${'msg_grad'.tr}",
                      style: TextStyle(fontSize: context.isPhone ? 22 : 28, color: AppColors.colNagrev),
                    )),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${'msg_settings_calibr_new'.tr}:",
                  style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colDarkGrey),
                ),
                const SizedBox(width: 20),
                SizedBox(
                    width: context.isPhone ? 100 : 200,
                    child: TextField(
                      controller: msc._textControllerMLK,
                      focusNode: msc._focusNodeMLK,
                      showCursor: true,
                      readOnly: true,
                      style: TextStyle(color: Colors.white, fontSize: context.isPhone ? 18 : 22),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.colDarkGrey3,
                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: context.isPhone ? 20 : 30),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.colDarkGrey, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          gapPadding: 0.0,
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.amber, width: 1.5),
                        ),
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${'msg_settings_calibr_hight'.tr}:",
                  style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colDarkGrey),
                ),
                const SizedBox(width: 20),
                // ОТКАЛИБРОВАТЬ
                ElevatedButton(
                  onPressed: () {
                    appc.calibrateSensor("S1", msc._textControllerMLK.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colNagrev,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: context.isPhone ? 10 : 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('msg_button_calibr'.tr, style: TextStyle(fontSize: context.isPhone ? 15 : 20, fontFamily: 'Rubik', color: AppColors.colDark)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${'msg_settings_calibr_low'.tr}:",
                  style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colDarkGrey),
                ),
                const SizedBox(width: 20),
                // ОТКАЛИБРОВАТЬ
                ElevatedButton(
                  onPressed: () {
                    appc.calibrateSensor("S2", msc._textControllerMLK.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colNagrev,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: context.isPhone ? 10 : 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('msg_button_calibr'.tr, style: TextStyle(fontSize: context.isPhone ? 15 : 20, fontFamily: 'Rubik', color: AppColors.colDark)),
                ),
              ],
            ),
          ],
        ));
  }

// Калибровка датчика воды
  Widget calibrateWater(BuildContext context) {
    return Flexible(
        flex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'msg_settings_calibr_water'.tr,
              style: TextStyle(fontSize: context.isPhone ? 20 : 26, color: AppColors.colWhite),
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${'msg_settings_calibr_current'.tr}:",
                  style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colDarkGrey),
                ),
                const SizedBox(width: 20),
                Obx(() => Text(
                      "${appc.currentTempWater} ${'msg_grad'.tr}",
                      style: TextStyle(fontSize: context.isPhone ? 22 : 28, color: AppColors.colNagrev),
                    )),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${'msg_settings_calibr_new'.tr}:",
                  style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colDarkGrey),
                ),
                const SizedBox(width: 20),
                SizedBox(
                    width: context.isPhone ? 100 : 200,
                    child: TextField(
                      controller: msc._textControllerWTR,
                      focusNode: msc._focusNodeWTR,
                      showCursor: true,
                      readOnly: true,
                      style: TextStyle(color: Colors.white, fontSize: context.isPhone ? 18 : 22),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.colDarkGrey3,
                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: context.isPhone ? 20 : 30),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.colDarkGrey, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          gapPadding: 0.0,
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.amber, width: 1.5),
                        ),
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${'msg_settings_calibr_hight'.tr}:",
                  style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colDarkGrey),
                ),
                const SizedBox(width: 20),
                // ОТКАЛИБРОВАТЬ
                ElevatedButton(
                  onPressed: () {
                    appc.calibrateSensor("S3", msc._textControllerWTR.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colNagrev,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: context.isPhone ? 10 : 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('msg_button_calibr'.tr, style: TextStyle(fontSize: context.isPhone ? 15 : 20, fontFamily: 'Rubik', color: AppColors.colDark)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${'msg_settings_calibr_low'.tr}:",
                  style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colDarkGrey),
                ),
                const SizedBox(width: 20),
                // ОТКАЛИБРОВАТЬ
                ElevatedButton(
                  onPressed: () {
                    appc.calibrateSensor("S4", msc._textControllerWTR.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colNagrev,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: context.isPhone ? 10 : 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('msg_button_calibr'.tr, style: TextStyle(fontSize: context.isPhone ? 15 : 20, fontFamily: 'Rubik', color: AppColors.colDark)),
                ),
              ],
            ),
          ],
        ));
  }

// Общие настройки
  Widget commonSettings(BuildContext context) {
    return Flexible(
        flex: 50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'msg_settings_common'.tr,
              style: TextStyle(fontSize: context.isPhone ? 20 : 26, color: AppColors.colWhite),
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${'msg_settings_lang'.tr}:",
                  style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colDarkGrey),
                ),
                const SizedBox(width: 20),
                Obx(() => DropdownButton(
                      value: msc.lang.value,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.colWhite,
                      ),
                      dropdownColor: AppColors.colDarkGrey3,
                      borderRadius: BorderRadius.circular(5),
                      style: const TextStyle(color: AppColors.colCurrNagrev),
                      items: msc.langs
                          .map((String items) => DropdownMenuItem(
                              value: items, child: Text(items, style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colWhite))))
                          .toList(),
                      onChanged: (value) {
                        msc._onLangChange(value);
                      },
                    )),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${'msg_settings_system'.tr}:",
                  style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colDarkGrey),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    SystemSettings.system();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colNagrev,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('msg_button_open'.tr, style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontFamily: 'Rubik', color: AppColors.colDark)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // BLUETOOTH
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${'msg_settings_bluetooth'.tr}:",
                  style: TextStyle(fontSize: context.isPhone ? 18 : 22, color: AppColors.colDarkGrey),
                ),
                const SizedBox(width: 30),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                ])
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Состояние:",
                  style: TextStyle(fontSize: context.isPhone ? 14 : 16, color: AppColors.colDarkGrey2),
                ),
                const SizedBox(width: 20),
                Obx(() => Text(
                      appc.blu.bluetoothState.value.toString(),
                      style: TextStyle(fontSize: context.isPhone ? 14 : 16, color: AppColors.colDarkGrey),
                    )),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Адрес адаптера:",
                  style: TextStyle(fontSize: context.isPhone ? 14 : 16, color: AppColors.colDarkGrey2),
                ),
                const SizedBox(width: 20),
                Obx(() => Text(
                      appc.blu.deviceAddress.value,
                      style: TextStyle(fontSize: context.isPhone ? 14 : 16, color: AppColors.colDarkGrey),
                    )),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Имя устройства:",
                  style: TextStyle(fontSize: context.isPhone ? 14 : 16, color: AppColors.colDarkGrey2),
                ),
                const SizedBox(width: 20),
                Obx(() => Text(
                      appc.blu.deviceName.value,
                      style: TextStyle(fontSize: context.isPhone ? 14 : 16, color: AppColors.colDarkGrey),
                    )),
              ],
            ),
          ],
        ));
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

class SettingsListItem extends StatelessWidget {
  final VoidCallback? onTap;
  final String? groupTitle;
  final Widget? title;
  final Widget? subtitle;

  const SettingsListItem({
    Key? key,
    this.groupTitle,
    this.title,
    this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (groupTitle != null)
        Padding(
            padding: context.isPhone ? const EdgeInsets.only(top: 20, bottom: 8) : const EdgeInsets.only(top: 30, bottom: 8),
            child: Text(
              groupTitle ?? '',
              style: TextStyle(fontFamily: 'Rubik', fontSize: context.isPhone ? 18 : 22, color: AppColors.colWhite),
            )),
      Card(
          color: AppColors.colDarkGrey4,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      splashColor: const Color.fromARGB(10, 255, 255, 255),
                      overlayColor: MaterialStateProperty.all(const Color.fromARGB(10, 255, 255, 255)),
                      onTap: onTap,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Flex(
                              direction: context.isLandscape ? Axis.horizontal : Axis.vertical,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: context.isLandscape ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                              children: [],
                            )),
                            // КРЕСТИК
                            Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: IconButton(
                                  icon: SvgPicture.asset(
                                    'assets/icons/svg/button_delete.svg',
                                    color: Colors.white,
                                    width: context.isPhone ? 22 : 30,
                                  ),
                                  onPressed: onTap,
                                )),
                          ],
                        ),
                      )))))
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
