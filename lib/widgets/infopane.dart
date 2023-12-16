import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/appcontroller.dart';
import '../variables/colors.dart';

class InfoPaneController extends GetxController {
  var maxValue = 100.0.obs;
  var currentValue = 1.0.obs;
  var reverse = false.obs;

  void changeMaxValue(double val) {
    maxValue.value = double.parse((val).toStringAsFixed(1));
  }

  void changeMaxValueInt(int val) {
    maxValue.value = val.toDouble();
  }

  double calcValue(bool isTime) {
    return reverse.value
        ? isTime
            ? maxValue.value != 0
                ? currentValue.value / maxValue.value
                : 0
            : currentValue.value != 0
                ? maxValue.value / currentValue.value
                : 0
        : currentValue.value / maxValue.value;
  }
}

class InfoPane extends StatelessWidget {
  final String name;
  final String activeTitle;
  final Color activeColor;
  final Color backColor;
  double minValue;
  double maxValue;
  double currentValue;
  final String label;
  final bool reverse;
  final bool isTime;

  InfoPane(
      {Key? key,
      required this.name,
      this.activeTitle = '',
      this.activeColor = AppColors.colNagrev,
      this.backColor = AppColors.colDarkGrey,
      this.minValue = 0,
      this.maxValue = 100,
      this.currentValue = 0.0,
      this.label = "",
      this.reverse = false,
      this.isTime = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    InfoPaneController ipc = Get.find<InfoPaneController>(tag: name);
    final appc = Get.find<AppController>();

    ipc.currentValue.value = currentValue;
    ipc.maxValue.value = maxValue;
    ipc.reverse.value = reverse;

    return Row(
      children: [
        Expanded(
            child: Container(
          //height: context.isPhone ? 100 : 144,
          padding: context.isPhone ? const EdgeInsets.fromLTRB(20, 10, 20, 18) : const EdgeInsets.fromLTRB(20, 20, 20, 20),
          margin: EdgeInsets.fromLTRB(0, 0, 0, context.isPhone ? 30 : 30),
          decoration: BoxDecoration(color: AppColors.colInfoPane, borderRadius: BorderRadius.circular(20.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (activeTitle != "")
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text(activeTitle.toUpperCase(),
                      style: TextStyle(
                        fontSize: context.isPhone ? 12 : 14,
                        color: AppColors.colDarkGrey,
                      )),
                ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() => Text(
                        name != 'viderzhka'
                            ? ipc.currentValue.value.toStringAsFixed(1)
                            : appc.getTime(ipc.currentValue.value.truncate()), //"${ipc.currentValue.value.truncate()}",
                        style: TextStyle(
                          fontSize: context.isPhone ? 40 : 50,
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.w700,
                          color: activeColor,
                        ))),
                    if (name != 'viderzhka')
                      Text(label,
                          style: TextStyle(
                            fontSize: context.isPhone ? 30 : 40,
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w500,
                            color: activeColor,
                          )),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() => Text(name != 'viderzhka' ? ipc.maxValue.value.toString() : appc.getTime(ipc.maxValue.value.truncate()),
                        style: TextStyle(
                          fontSize: context.isPhone ? 28 : 34,
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.w700,
                          color: backColor,
                        ))),
                    if (name != 'viderzhka')
                      Text(label,
                          style: TextStyle(
                            fontSize: context.isPhone ? 24 : 26,
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w500,
                            color: backColor,
                          )),
                  ],
                ),
              ]),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                      child: SizedBox(
                          height: context.isPhone ? 10 : 16,
                          child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              child: Obx(
                                () => LinearProgressIndicator(
                                  value: name != 'viderzhka' ? ipc.calcValue(false) : ipc.calcValue(true),
                                  minHeight: 16,
                                  backgroundColor: backColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                                ),
                              ))))
                ],
              )
            ],
          ),
        )),
      ],
    );
  }
}
