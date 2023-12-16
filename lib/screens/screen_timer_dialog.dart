//import 'package:flutter/animation.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/appcontroller.dart';
import '../widgets/timepicker.dart';
import '../variables/colors.dart';

class TimerDialog extends StatelessWidget {
  TimerDialog({Key? key}) : super(key: key);
  final appc = Get.find<AppController>();
  final ctpc = Get.find<CustomTimePickerController>(tag: "app_timer");

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 260,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text('msg_timer_set'.tr,
                style: TextStyle(
                  fontSize: context.isPhone ? 20 : 24,
                  fontFamily: 'Rubik',
                  color: AppColors.colWhite,
                )),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            CustomTimePicker(name: 'app_timer', value: appc.appTimer.value, onChanged: (value) {}),
          ]),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // УСТАНОВИТЬ
                appc.appTimer.value == 0
                    ? ElevatedButton(
                        onPressed: () {
                          appc.startTimerApp(ctpc.getTimeSeconds());
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.colNagrev,
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text('msg_button_set'.tr, style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontFamily: 'Rubik', color: AppColors.colDark)),
                      )
                    :
                    // СБРОСИТЬ
                    ElevatedButton(
                        onPressed: () {
                          appc.stopTimerApp();
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.colNagrev,
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child:
                            Text('msg_button_reset2'.tr, style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontFamily: 'Rubik', color: AppColors.colDark)),
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
                  },
                  child: Text('msg_button_cancel'.tr, style: TextStyle(fontSize: context.isPhone ? 16 : 20, fontFamily: 'Rubik')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showTimerDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (_) => OrientationBuilder(builder: (context, orientation) {
            return GestureDetector(
                onTap: () => {Get.back()},
                child: Scaffold(
                    backgroundColor: const Color.fromARGB(140, 0, 0, 0),
                    body: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                        child: GestureDetector(
                          onTap: () => {},
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
                                return TimerDialog();
                              },
                            ),
                          ),
                        ))));
          })).then((val) {});
}
