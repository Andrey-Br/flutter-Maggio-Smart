//ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../variables/colors.dart';
import 'infopane.dart';

class CustomTimePickerController extends GetxController {
  var currentHour = 0.obs;
  var currentMin = 0.obs;
  var currentSec = 0.obs;

  final hValues = Iterable<int>.generate(24).toList();
  final mValues = Iterable<int>.generate(60).toList();

  List<Widget> modelBuilder<M>(List<M> models, Widget Function(int index, M model) builder) =>
      models.asMap().map<int, Widget>((index, model) => MapEntry(index, builder(index, model))).values.toList();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    setTimeSeconds(0);
    super.onClose();
  }

  int getTimeSeconds() {
    return currentHour.value * 60 * 60 + currentMin.value * 60 + currentSec.value;
  }

  void setTimeSeconds(int seconds) {
    currentHour.value = seconds ~/ 3600;
    currentMin.value = (seconds - (currentHour.value * 3600)) ~/ 60;
    currentSec.value = seconds - (currentHour.value * 3600) - (currentMin.value * 60);
  }
}

class CustomTimePicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String name;
  String? text;
  final int min;
  final int max;
  final Color activeColor;

  CustomTimePicker({
    Key? key,
    required this.value,
    required this.onChanged,
    this.name = "",
    this.text,
    this.activeColor = Colors.black,
    this.min = 0,
    this.max = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CustomTimePickerController ctpc = Get.find<CustomTimePickerController>(tag: name);

    if ({'app_timer'}.contains(name)) {
      ctpc.currentHour.value = 0;
      ctpc.currentMin.value = 0;
      ctpc.currentSec.value = 0;
    }
    return OrientationBuilder(
        builder: (context, orientation) => Material(
              color: Colors.transparent,
              child: Container(
                margin: context.isLandscape ? const EdgeInsets.only(top: 10, bottom: 10) : const EdgeInsets.only(top: 10, bottom: 10),
                child: Flex(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    direction: context.isLandscape ? Axis.horizontal : Axis.vertical,
                    children: [
                      if (text != null)
                        SizedBox(
                          width: context.isLandscape ? 180 : Get.width,
                          child: Text((text ?? '').toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: context.isPhone ? 15 : 18,
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w300,
                                color: AppColors.colLightGrey,
                              )),
                        ),
                      context.isLandscape ? const SizedBox(width: 20) : const SizedBox(height: 30),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Obx(() => SizedBox(
                              height: context.isPhone ? 64 : 80,
                              width: context.isPhone ? 64 : 80,
                              child: CupertinoPicker(
                                itemExtent: context.isPhone ? 36 : 42,
                                diameterRatio: 1.1,
                                looping: true,
                                onSelectedItemChanged: (value) {
                                  ctpc.currentHour.value = value;
                                  onChanged(ctpc.getTimeSeconds());
                                  if ({'viderzhka'}.contains(name)) {
                                    Get.find<InfoPaneController>(tag: 'viderzhka').changeMaxValueInt(ctpc.getTimeSeconds());
                                  }
                                },
                                selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                                  background: AppColors.colDarkGrey.withOpacity(0.3),
                                ),
                                children: ctpc.modelBuilder<int>(
                                  ctpc.hValues,
                                  (index, value) {
                                    final isSelected = ctpc.currentHour.value == index;

                                    return Center(
                                      child: Text(
                                        "$value",
                                        style: TextStyle(
                                          color: isSelected ? AppColors.colWhite : AppColors.colDarkGrey2,
                                          fontSize: isSelected
                                              ? context.isPhone
                                                  ? 28
                                                  : 36
                                              : context.isPhone
                                                  ? 24
                                                  : 28,
                                          fontFamily: 'Rubik',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )),
                        Text(
                          "час  ",
                          style: TextStyle(
                            color: AppColors.colDarkGrey,
                            fontSize: context.isPhone ? 16 : 20,
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Obx(() => SizedBox(
                              height: context.isPhone ? 64 : 80,
                              width: context.isPhone ? 64 : 80,
                              child: CupertinoPicker(
                                itemExtent: context.isPhone ? 36 : 42,
                                diameterRatio: 1.1,
                                looping: true,
                                onSelectedItemChanged: (value) {
                                  ctpc.currentMin.value = value;
                                  onChanged(ctpc.getTimeSeconds());
                                  if ({'viderzhka'}.contains(name)) {
                                    Get.find<InfoPaneController>(tag: 'viderzhka').changeMaxValueInt(ctpc.getTimeSeconds());
                                  }
                                },
                                selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                                  background: AppColors.colDarkGrey.withOpacity(0.3),
                                ),
                                children: ctpc.modelBuilder<int>(
                                  ctpc.mValues,
                                  (index, value) {
                                    final isSelected = ctpc.currentMin.value == index;

                                    return Center(
                                      child: Text(
                                        "$value",
                                        style: TextStyle(
                                          color: isSelected ? AppColors.colWhite : AppColors.colDarkGrey2,
                                          fontSize: isSelected
                                              ? context.isPhone
                                                  ? 28
                                                  : 36
                                              : context.isPhone
                                                  ? 24
                                                  : 28,
                                          fontFamily: 'Rubik',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )),
                        Text(
                          "мин  ",
                          style: TextStyle(
                            color: AppColors.colDarkGrey,
                            fontSize: context.isPhone ? 16 : 20,
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Obx(
                          () => SizedBox(
                            height: context.isPhone ? 64 : 80,
                            width: context.isPhone ? 64 : 80,
                            child: CupertinoPicker(
                              itemExtent: context.isPhone ? 36 : 42,
                              diameterRatio: 1.1,
                              looping: true,
                              onSelectedItemChanged: (value) {
                                ctpc.currentSec.value = value;
                                onChanged(ctpc.getTimeSeconds());
                                if ({'viderzhka'}.contains(name)) {
                                  Get.find<InfoPaneController>(tag: 'viderzhka').changeMaxValueInt(ctpc.getTimeSeconds());
                                }
                              },
                              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                                background: AppColors.colDarkGrey.withOpacity(0.3),
                              ),
                              children: ctpc.modelBuilder<int>(
                                ctpc.mValues,
                                (index, value) {
                                  final isSelected = ctpc.currentSec.value == index;

                                  return Center(
                                    child: Text(
                                      "$value",
                                      style: TextStyle(
                                        color: isSelected ? AppColors.colWhite : AppColors.colDarkGrey2,
                                        fontSize: isSelected
                                            ? context.isPhone
                                                ? 28
                                                : 36
                                            : context.isPhone
                                                ? 24
                                                : 28,
                                        fontFamily: 'Rubik',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Text(
                          "сек",
                          style: TextStyle(
                            color: AppColors.colDarkGrey,
                            fontSize: context.isPhone ? 16 : 20,
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ])
                    ]),
              ),
            ));
  }
}
