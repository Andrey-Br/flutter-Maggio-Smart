//ignore: must_be_immutable
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../variables/colors.dart';
import 'infopane.dart';

class CustomSliderController extends GetxController {
  var range = 1.0.obs;
  var min = 0.0.obs;
  var max = 100.0.obs;

  void setRange(double val) {
    range.value = val; //.truncate();
  }

  void _increment(double val) {
    if (range.value < max.value) {
      range.value += val;
    }
  }

  void _decrement(double val) {
    if (range.value > min.value) {
      range.value -= val;
      if (range.value < 0) range.value = 0;
    }
  }
}

class _ThumbShape extends RoundSliderThumbShape {
  final _indicatorShape = const PaddleSliderValueIndicatorShape();

  const _ThumbShape();

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required Size sizeWithOverflow,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double textScaleFactor,
      required double value}) {
    super.paint(context, center,
        activationAnimation: activationAnimation,
        enableAnimation: enableAnimation,
        isDiscrete: isDiscrete,
        labelPainter: labelPainter,
        parentBox: parentBox,
        sizeWithOverflow: sizeWithOverflow,
        sliderTheme: sliderTheme,
        textDirection: textDirection,
        textScaleFactor: textScaleFactor,
        value: value);

    _indicatorShape.paint(context, center,
        activationAnimation: const AlwaysStoppedAnimation(1),
        enableAnimation: enableAnimation,
        isDiscrete: isDiscrete,
        labelPainter: labelPainter,
        parentBox: parentBox,
        sizeWithOverflow: sizeWithOverflow,
        sliderTheme: sliderTheme,
        textDirection: textDirection,
        textScaleFactor: 0.8,
        value: value);
  }
}

class CustomSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  String? text;
  final String label;
  final String name;
  final Color activeColor;
  final double min;
  final double max;
  final double div;
  bool round;
  int? divisions;
  Timer? _timerHold;

  CustomSlider(
      {Key? key,
      required this.value,
      required this.onChanged,
      this.text,
      this.label = "",
      this.name = "",
      this.activeColor = Colors.black,
      this.min = 0.0,
      this.max = 10.0,
      this.div = 1.0,
      this.round = true,
      this.divisions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CustomSliderController csc = name != "" ? Get.find<CustomSliderController>(tag: name) : Get.put(CustomSliderController());

    csc.min.value = min <= max ? min : max;
    csc.max.value = max >= min ? max : min;
    csc.range.value = (value >= min) && (value <= max) ? value : csc.min.value;

    return OrientationBuilder(
        builder: (context, orientation) => Material(
              color: Colors.transparent,
              child: Container(
                margin: context.isLandscape ? const EdgeInsets.only(top: 20, bottom: 10) : const EdgeInsets.only(top: 10, bottom: 10),
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
                      context.isLandscape ? const SizedBox(width: 20) : const SizedBox(height: 40),
                      Expanded(
                          flex: context.isLandscape ? 1 : 0,
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            // ДЕКРЕМЕНТ
                            Flexible(
                              flex: 0,
                              child: GestureDetector(
                                  onLongPress: () {
                                    _timerHold = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
                                      //csc._decrement(divisions != null ? (max - min) ~/ divisions! : 1);
                                      csc._decrement(div);
                                    });
                                  },
                                  onLongPressUp: () {
                                    onChanged(csc.range.value);
                                    if ({'nagrev', 'viderzhka', 'oxlazhdenie'}.contains(name)) {
                                      Get.find<InfoPaneController>(tag: name).changeMaxValue(csc.range.value);
                                    }
                                    _timerHold?.cancel();
                                  },
                                  child: SizedBox.fromSize(
                                      size: context.isPhone ? const Size(40, 40) : const Size(50, 50),
                                      child: ClipOval(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            splashColor: const Color.fromARGB(50, 255, 255, 255),
                                            onTap: () {
                                              //csc._decrement(divisions != null ? (max - min) ~/ divisions! : 1);
                                              csc._decrement(div);

                                              onChanged(csc.range.value);
                                              if ({'nagrev', 'viderzhka', 'oxlazhdenie'}.contains(name)) {
                                                Get.find<InfoPaneController>(tag: name).changeMaxValue(csc.range.value);
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SvgPicture.asset(
                                                'assets/icons/svg/icon_minus.svg',
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ))),
                            ),

                            // СЛАЙДЕР
                            Flexible(
                              flex: 1,
                              child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    showValueIndicator: ShowValueIndicator.never,
                                    trackHeight: context.isPhone ? 5 : 7,
                                    trackShape: const RoundedRectSliderTrackShape(),
                                    thumbShape: const _ThumbShape(),
                                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                                    tickMarkShape: null, //RoundSliderTickMarkShape(),
                                    valueIndicatorShape: null, //PaddleSliderValueIndicatorShape(),
                                    valueIndicatorColor: const Color.fromARGB(0, 0, 0, 0),
                                    valueIndicatorTextStyle: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: context.isPhone ? 20 : 24,
                                    ),
                                  ),
                                  child: Obx(
                                    () => Slider(
                                        value: csc.range.value,
                                        min: csc.min.value,
                                        max: csc.max.value,
                                        divisions: divisions,
                                        activeColor: activeColor,
                                        inactiveColor: AppColors.colDarkGrey,
                                        label: round ? csc.range.truncate().toString() + label : csc.range.toString() + label,
                                        onChanged: (double value) {
                                          if (value - value.truncate() > 0.5) {
                                            value = value.truncate().toDouble();
                                          } else {
                                            value = value.truncate().toDouble() + 0.5;
                                          }
                                          csc.setRange(value > max ? max : value);
                                          if ({'nagrev', 'viderzhka', 'oxlazhdenie'}.contains(name)) {
                                            Get.find<InfoPaneController>(tag: name).changeMaxValue(value);
                                          }
                                        },
                                        onChangeEnd: (double value) {
                                          if (value - value.truncate() > 0.5) {
                                            value = value.truncate().toDouble();
                                          } else {
                                            value = value.truncate().toDouble() + 0.5;
                                          }
                                          onChanged(value > max ? max : value);
                                        }),
                                  )),
                            ),

                            // ИНКРЕМЕНТ
                            Flexible(
                                flex: 0,
                                child: GestureDetector(
                                    onLongPress: () {
                                      _timerHold = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
                                        //csc._increment(divisions != null ? (max - min) ~/ divisions! : 1);
                                        csc._increment(div);
                                      });
                                    },
                                    onLongPressUp: () {
                                      onChanged(csc.range.value);
                                      if ({'nagrev', 'viderzhka', 'oxlazhdenie'}.contains(name)) {
                                        Get.find<InfoPaneController>(tag: name).changeMaxValue(csc.range.value);
                                      }
                                      _timerHold?.cancel();
                                    },
                                    child: SizedBox.fromSize(
                                      size: context.isPhone ? const Size(40, 40) : const Size(50, 50),
                                      child: ClipOval(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            splashColor: const Color.fromARGB(50, 255, 255, 255), // splash color
                                            onTap: () {
                                              //csc._increment(divisions != null ? (max - min) ~/ divisions! : 1);
                                              csc._increment(div);
                                              onChanged(csc.range.value);
                                              if ({'nagrev', 'viderzhka', 'oxlazhdenie'}.contains(name)) {
                                                Get.find<InfoPaneController>(tag: name).changeMaxValue(csc.range.value);
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SvgPicture.asset(
                                                'assets/icons/svg/icon_plus.svg',
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ))),
                          ]))
                    ]),
              ),
            ));
  }
}
