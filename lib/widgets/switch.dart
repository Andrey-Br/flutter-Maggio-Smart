import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../variables/colors.dart';

class CustomSwitchController extends GetxController with GetSingleTickerProviderStateMixin {
  var _checked = false;
  late AnimationController _animationController;

  @override
  void onInit() {
    super.onInit();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 60));
  }

/*   @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  } */

  void _onTap() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    _checked = !_checked; //.toggle();
  }
}

class CustomSwitch extends GetWidget {
  final ValueChanged<bool> valueChanged;
  final bool checked;
  final String text;
  final String name;
  final Color activeColor;
  final Color activeTextColor;
  final Color inactiveColor;
  final Color inactiveTextColor;
  final String activeText;
  final String inactiveText;

  CustomSwitch(
      {Key? key,
      required this.valueChanged,
      this.text = "",
      this.checked = false,
      this.name = "",
      this.activeColor = AppColors.colViderzhka,
      this.inactiveColor = const Color(0xFF636D84),
      this.activeText = 'ВКЛ',
      this.inactiveText = 'ВЫКЛ',
      this.activeTextColor = Colors.white,
      this.inactiveTextColor = Colors.white70})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //CustomSwitchController cswc;
    //name != "" ? cswc = Get.find<CustomSwitchController>(tag: name) : cswc = Get.put(CustomSwitchController());
    //CustomSwitchController cswc = Get.find<CustomSwitchController>(tag: name);
    CustomSwitchController cswc = Get.put(CustomSwitchController());
    cswc._checked = checked;

    Animation circleAnimation =
        AlignmentTween(begin: cswc._checked ? Alignment.centerRight : Alignment.centerLeft, end: cswc._checked ? Alignment.centerLeft : Alignment.centerRight)
            .animate(CurvedAnimation(parent: cswc._animationController, curve: Curves.linear));

    return Row(children: [
      if (text != "")
        Text(text.toUpperCase(),
            style: TextStyle(
              fontSize: context.isPhone ? 15 : 18,
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w300,
              color: AppColors.colLightGrey,
            )),
      const SizedBox(width: 30),
      AnimatedBuilder(
        animation: cswc._animationController,
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              cswc._onTap();
              valueChanged(cswc._checked);
            },
            child: Container(
              width: context.isPhone ? 80 : 90,
              height: context.isPhone ? 30 : 35,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: circleAnimation.value == Alignment.centerLeft ? inactiveColor : activeColor),
              child: Row(
                mainAxisAlignment: circleAnimation.value == Alignment.centerLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: <Widget>[
                  circleAnimation.value == Alignment.centerRight
                      ? Container(
                          margin: EdgeInsets.only(right: context.isPhone ? 7 : 10),
                          child: Text(
                            activeText,
                            style: TextStyle(color: activeTextColor, fontWeight: FontWeight.w500, fontSize: context.isPhone ? 11 : 13),
                          ),
                        )
                      : Container(),
                  Align(
                    alignment: circleAnimation.value,
                    child: Container(
                      width: context.isPhone ? 30 : 35,
                      height: context.isPhone ? 30 : 35,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                  ),
                  circleAnimation.value == Alignment.centerLeft
                      ? Container(
                          margin: EdgeInsets.only(left: context.isPhone ? 3 : 6),
                          child: Text(
                            inactiveText,
                            style: TextStyle(color: inactiveTextColor, fontWeight: FontWeight.w500, fontSize: context.isPhone ? 11 : 13),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          );
        },
      )
    ]);
  }
}
