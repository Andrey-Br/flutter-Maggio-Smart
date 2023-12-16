import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../variables/colors.dart';

class SelectButton extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final List list;
  final String? text;
  final bool disable;
  final Color activeColor;
  final Color inActiveColor;
  final Color activeTextColor;
  final Color inActiveTextColor;

  SelectButton(
      {Key? key,
      required List<String> this.list,
      required this.value,
      required this.onChanged,
      this.text,
      this.disable = false,
      this.activeColor = AppColors.colNagrev,
      this.inActiveColor = AppColors.colLightGrey,
      this.activeTextColor = Colors.black,
      this.inActiveTextColor = AppColors.colWhite})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int isActive = value;
    return Container(
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
                        color: disable ? AppColors.colDarkGrey2 : AppColors.colLightGrey,
                      )),
                ),
              context.isLandscape ? const SizedBox(width: 20) : const SizedBox(height: 25),
              Expanded(
                  flex: context.isLandscape ? 1 : 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      for (var i in list)
                        Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        disabledBackgroundColor: AppColors.colBackground,
                                        disabledForegroundColor: AppColors.colDarkGrey2,
                                        backgroundColor: isActive == list.indexOf(i) ? activeColor : AppColors.colDarkGrey3,
                                        foregroundColor: isActive == list.indexOf(i) ? Colors.black : AppColors.colWhite,
                                        side: BorderSide(
                                            width: 1.0,
                                            color: isActive == list.indexOf(i)
                                                ? disable
                                                    ? AppColors.colDarkGrey2
                                                    : activeColor
                                                : disable
                                                    ? AppColors.colDarkGrey2
                                                    : AppColors.colDarkGrey),
                                        minimumSize: context.isPhone ? const Size(90, 36) : const Size(116, 46),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        textStyle: TextStyle(
                                          fontSize: context.isPhone ? 20 : 24,
                                          fontFamily: 'Rubik',
                                          fontWeight: FontWeight.w300,
                                        )),
                                    onPressed: disable ? null : () => {isActive = list.indexOf(i), onChanged(isActive)},
                                    child: Text(i)))),
                    ],
                  ))
            ]));
  }
}
