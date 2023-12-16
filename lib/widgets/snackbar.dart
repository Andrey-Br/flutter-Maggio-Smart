import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../variables/colors.dart';

class CustomSnackbarController extends GetxController with GetSingleTickerProviderStateMixin {
  //late final AnimationController animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  //late final Animation<double> animation = CurveTween(curve: Curves.easeOutCirc).animate(animationController);
  late AudioPlayer _player;
  late RxBool resultDialog = false.obs;

  @override
  void onInit() {
    super.onInit();
    //animation = CurveTween(curve: Curves.easeOutCirc).animate(animationController);
    _player = AudioPlayer();
  }

  @override
  void onClose() {
    //animationController.dispose();
    _player.dispose();
    super.onClose();
  }

  void showNotification(String text,
      {String? iconPath,
      String? soundPath,
      SnackPosition position = SnackPosition.BOTTOM,
      int? duration,
      Color backgroundColor = const Color(0xAAFFFFFF),
      Color iconColor = AppColors.colDark,
      Color textColor = AppColors.colDark}) async {
    if (soundPath != null) {
      try {
        await _player.setAsset(soundPath);
        _player.play();
      } catch (_) {}
    }
    Get.snackbar('', '',
        duration: Duration(seconds: duration ?? 99999999),
        messageText: Padding(
            padding: const EdgeInsets.only(bottom: 25, left: 35, right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconPath != null) SvgPicture.asset(iconPath, color: iconColor, alignment: Alignment.center, width: 50),
                const SizedBox(width: 20),
                Flexible(child: Text(text, style: TextStyle(fontSize: 28, fontFamily: 'Rubik', color: textColor)))
              ],
            )),
        mainButton: duration == null
            ? TextButton(
                onPressed: () {
                  Get.back();
                },
                child: SvgPicture.asset('assets/icons/svg/button_delete.svg', color: iconColor, alignment: Alignment.center, width: 20))
            : null,
        dismissDirection: DismissDirection.horizontal,
        snackPosition: position,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        padding: const EdgeInsets.all(0),
        backgroundColor: backgroundColor,
        barBlur: 10.0);
  }

  Future<bool> showCenterDialog({
    //required BuildContext context,
    String? title,
    String? text,
    String? primaryBtnText,
    String? secondaryBtnText,
    String? iconPath,
    Color titleColor = AppColors.colWhite,
    Color textColor = AppColors.colDarkGrey,
    Color windowColor = AppColors.colBackground,
    Color iconColor = AppColors.colWhite,
    Widget? child,
    bool closeOnTapBG = true,
    String? soundPath,
    VoidCallback? onPrimary,
    VoidCallback? onSecondary,
  }) async {
    if (soundPath != null) {
      try {
        await _player.setAsset(soundPath);
        _player.play();
      } catch (_) {}
    }
    return resultDialog.value = await Get.defaultDialog(
          title: '',
          titleStyle: const TextStyle(fontSize: 0),
          barrierDismissible: closeOnTapBG,
          radius: 10,
          backgroundColor: windowColor,
          contentPadding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (iconPath != null)
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                      child: SvgPicture.asset(iconPath, color: iconColor, alignment: Alignment.center, width: 70)),
                if (title != null)
                  Padding(
                      padding: iconPath != null ? const EdgeInsets.fromLTRB(0, 20, 0, 0) : const EdgeInsets.fromLTRB(0, 40, 0, 0),
                      child: Text(title, style: TextStyle(fontSize: 24, fontFamily: 'Rubik', color: titleColor, fontWeight: FontWeight.w300))),
                if (text != null)
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                      child: Text(text, style: TextStyle(fontSize: 20, fontFamily: 'Rubik', color: textColor))),
                if (child != null) Padding(padding: const EdgeInsets.fromLTRB(0, 40, 0, 0), child: child),
                if ((primaryBtnText != null) || (secondaryBtnText != null))
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // КНОПКА ДЕЙСТВИЯ
                          if (primaryBtnText != null)
                            ElevatedButton(
                              onPressed: () {
                                onPrimary?.call();
                                Get.back(result: true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.colNagrev,
                                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(primaryBtnText, style: const TextStyle(fontSize: 20, fontFamily: 'Rubik', color: AppColors.colDark)),
                            ),
                          // КНОПКА ОТМЕНА
                          if (secondaryBtnText != null)
                            TextButton(
                              style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all<Color>(AppColors.colDarkGrey),
                                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (states.contains(MaterialState.hovered)) return Colors.white.withOpacity(0.04);
                                      if (states.contains(MaterialState.focused) || states.contains(MaterialState.pressed))
                                        return Colors.white.withOpacity(0.12);
                                      return null;
                                    },
                                  ),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
                              onPressed: () {
                                onSecondary?.call();
                                Get.back(result: false);
                              },
                              child: Text(secondaryBtnText, style: const TextStyle(fontSize: 20, fontFamily: 'Rubik')),
                            ),
                        ],
                      )),
              ],
            ),
          ),
        ) ??
        false;
  }
}
