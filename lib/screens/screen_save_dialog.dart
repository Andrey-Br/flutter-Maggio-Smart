//import 'package:flutter/animation.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/appcontroller.dart';
import '../variables/colors.dart';
import '../models/settings.dart';
import '../widgets/keyboard.dart';
import '../widgets/snackbar.dart';

class SaveDialogController extends GetxController {
  var receptName = ''.obs;
  var shiftEnabled = false.obs;
  var isNumericMode = false.obs;
  var langKeyboard = "RU".obs;
  double widthDialog = 500;
  double heightDialog = 240;
  var paddingTopDialog = (Get.height / 2 - 140).obs;
  final _formKey = GlobalKey<FormState>();
  late BuildContext _context;
  final FocusNode _focus = FocusNode();
  final TextEditingController receptNameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _focus.addListener(_onFocusChange);
  }

  @override
  void onClose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    receptNameController.dispose();
    super.onClose();
  }

  void _unFocus() {
    FocusScope.of(_context).unfocus();
    if (_focus.hasFocus) {
      Navigator.of(_context).pop();
    }
  }

  _onKeyPress(VirtualKeyboardKey key) {
    if (key.keyType == VirtualKeyboardKeyType.String) {
      receptName.value = receptName.value + (shiftEnabled.value ? key.capsText : key.text);
    } else if (key.keyType == VirtualKeyboardKeyType.Action) {
      switch (key.action) {
        case VirtualKeyboardKeyAction.Backspace:
          if (receptName.value.isEmpty) return;
          receptName.value = receptName.value.substring(0, receptName.value.length - 1);
          break;
        case VirtualKeyboardKeyAction.Space:
          receptName.value = receptName.value + key.text;
          break;
        case VirtualKeyboardKeyAction.Shift:
          shiftEnabled.toggle();
          break;
        case VirtualKeyboardKeyAction.Lang:
          if (langKeyboard.value == "RU") {
            langKeyboard.value = "EN";
          } else if (langKeyboard.value == "EN") {
            langKeyboard.value = "RU";
          }
          break;
        default:
      }
    }
    receptNameController.text = receptName.value;
    receptNameController.selection = TextSelection.collapsed(offset: receptNameController.text.length);
  }

  void _onFocusChange() {
    if (_focus.hasFocus) {
      paddingTopDialog.value = 0;
      showBottomSheet(
        context: _context,
        enableDrag: false,
        backgroundColor: const Color.fromARGB(255, 95, 100, 130),
        builder: (context) => Obx(
          () => VirtualKeyboard(
              height: context.isPhone ? 200 : 300,
              fontSize: context.isPhone ? 22 : 28,
              textColor: Colors.white,
              type: langKeyboard.value == "RU" ? VirtualKeyboardType.AlphanumericRU : VirtualKeyboardType.AlphanumericEN,
              onKeyPress: _onKeyPress),
        ),
      );
    } else {
      paddingTopDialog.value = Get.height / 2 - 140;
    }
  }
}

/* void showSaveDialog(BuildContext context) {
  final appc = Get.find<AppController>();
  final SaveDialogController sdc = Get.put(SaveDialogController());
  final CustomSnackbarController sb = Get.put(CustomSnackbarController());

  sdc._context = context;
  sb
      .showCenterDialog(
          context: context,
          closeOnTapBG: false,
          title: "msg_recept_name".tr,
          primaryBtnText: 'msg_button_save'.tr,
          secondaryBtnText: 'msg_button_cancel'.tr,
          soundPath: appc.isSoundEnable.value ? 'assets/audio/ding.mp3' : null,
          onPrimary: () {
            if (sdc.receptNameController.text != '') {
              var settings = AppSettings(
                  receptName: sdc.receptNameController.text,
                  selectNagrev: appc.selectNagrev.value,
                  selectViderzhka: appc.selectViderzhka.value,
                  selectOxlazhdenie: appc.selectOxlazhdenie.value,
                  selectMeshalka: appc.selectMeshalka.value,
                  nagrevTemp: appc.nagrevTemp.value,
                  nagrevPower: appc.nagrevPower.value,
                  viderzhkaTime: appc.viderzhkaTime.value,
                  oxlazhdenieTemp: appc.oxlazhdenieTemp.value,
                  mixerAuto: appc.mixerAuto.value,
                  mixerSpeed: appc.mixerSpeed.value,
                  mixerTimeAuto: appc.mixerTimeAuto.value);
              appc.addSettings(settings);
              Get.back();
              Get.back();
              sb.showNotification(
                'msg_recept_save_success'.tr,
                duration: 3,
                iconPath: 'assets/icons/svg/button_save.svg',
              );
            }
          },
          onSecondary: () {
            Get.back();
          },
          child: TextField(
            controller: sdc.receptNameController,
            focusNode: sdc._focus,
            showCursor: true,
            readOnly: true,
            style: TextStyle(color: Colors.white, fontSize: context.isPhone ? 18 : 22),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromARGB(43, 255, 255, 255),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color.fromARGB(255, 161, 161, 161), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                gapPadding: 0.0,
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.amber, width: 1.5),
              ),
            ),
          ))
      .then((val) {
    sdc.receptNameController.clear();
    sdc.receptName.value = '';
  });
}
 */

class SaveDialog extends StatelessWidget {
  SaveDialog({Key? key}) : super(key: key);
  final appc = Get.find<AppController>();
  final sb = Get.put(CustomSnackbarController());
  final SaveDialogController sdc = Get.put(SaveDialogController());

  @override
  Widget build(BuildContext context) {
    sdc._context = context;
    return Form(
        key: sdc._formKey,
        child: SizedBox(
          width: context.isPhone ? 400 : sdc.widthDialog, //500,
          height: context.isPhone ? 200 : sdc.heightDialog, //240,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Text('msg_recept_name'.tr,
                    style: TextStyle(
                      fontSize: context.isPhone ? 20 : 24,
                      fontFamily: 'Rubik',
                      color: AppColors.colWhite,
                    )),
              ),
              TextFormField(
                controller: sdc.receptNameController,
                focusNode: sdc._focus,
                showCursor: true,
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'msg_recept_save_error_empty'.tr;
                  }
                  if (appc.checkReceptName(sdc.receptNameController.text)) {
                    return 'msg_recept_save_error_name'.tr;
                  }
                  return null;
                },
                style: TextStyle(color: Colors.white, fontSize: context.isPhone ? 18 : 22),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(43, 255, 255, 255),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 161, 161, 161), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    gapPadding: 0.0,
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.amber, width: 1.5),
                  ),
                  errorStyle: const TextStyle(color: AppColors.colButtonStart),
                  errorBorder:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.colButtonStart, width: 1.5)),
                  focusedErrorBorder:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.colButtonStart, width: 1.5)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // СОХРАНИТЬ
                    ElevatedButton(
                      onPressed: () {
                        if (sdc._formKey.currentState!.validate()) {
                          var settings = AppSettings(
                              receptName: sdc.receptNameController.text,
                              selectNagrev: appc.selectNagrev.value,
                              selectViderzhka: appc.selectViderzhka.value,
                              selectOxlazhdenie: appc.selectOxlazhdenie.value,
                              selectMeshalka: appc.selectMeshalka.value,
                              nagrevTemp: appc.nagrevTemp.value,
                              nagrevPower: appc.nagrevPower.value,
                              viderzhkaTime: appc.viderzhkaTime.value,
                              oxlazhdenieTemp: appc.oxlazhdenieTemp.value,
                              mixerAuto: appc.mixerAuto.value,
                              mixerSpeed: appc.mixerSpeed.value,
                              mixerTimeAuto: appc.mixerTimeAuto.value);
                          appc.addSettings(settings);
                          Get.back();
                          Get.back();
                          sb.showNotification(
                            'msg_recept_save_success'.tr,
                            duration: 3,
                            iconPath: 'assets/icons/svg/button_save.svg',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.colNagrev,
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text('msg_button_save'.tr, style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontFamily: 'Rubik', color: AppColors.colDark)),
                    ),
                    // ОТМЕНА
                    TextButton(
                      style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(AppColors.colDarkGrey),
                          overlayColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.hovered)) return Colors.amber.withOpacity(0.04);
                              if (states.contains(MaterialState.focused) || states.contains(MaterialState.pressed)) return Colors.amber.withOpacity(0.12);
                              return null;
                            },
                          ),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
                      onPressed: () {
                        Get.back();
                        Get.back();
                      },
                      child: Text('msg_button_cancel'.tr, style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontFamily: 'Rubik')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

void showSaveDialog(BuildContext context) {
  final SaveDialogController sdc = Get.put(SaveDialogController());

  showDialog(
      context: context,
      builder: (_) => OrientationBuilder(builder: (context, orientation) {
            sdc.paddingTopDialog.value = Get.height / 2 - 140;
            return GestureDetector(
                onTap: () => {
                      if (!sdc._focus.hasFocus) {Get.back()} else {sdc._unFocus()}
                    },
                child: Scaffold(
                    backgroundColor: const Color.fromARGB(140, 0, 0, 0),
                    body: Obx(() => SingleChildScrollView(
                        padding: EdgeInsets.only(top: sdc.paddingTopDialog.value),
                        child: GestureDetector(
                            onTap: () => sdc._unFocus(),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                              child: AlertDialog(
                                backgroundColor: AppColors.colBackground,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                content: Builder(
                                  builder: (context) {
                                    return SaveDialog();
                                  },
                                ),
                              ),
                            ))))));
          })).then((val) {
    sdc.receptNameController.clear();
    sdc.receptName.value = '';
  });
}
