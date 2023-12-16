import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../variables/colors.dart';
import '../controllers/appcontroller.dart';
import 'infopane.dart';
import 'timepicker.dart';

class HelperButtonController extends GetxController {
  final appc = Get.find<AppController>();
  var pressedVal = 0.0.obs;

  void onPressed(String v) {
    pressedVal.value = double.parse(v);
  }
}

class HelperButton extends StatelessWidget {
  final String text;
  final String label;
  final String name;
  List list;

  HelperButton({Key? key, required this.name, this.text = "", this.label = "", required List<String> this.list}) : super(key: key);

  final HelperButtonController hbc = Get.put(HelperButtonController());

  void setGlobalVar(double value) {
    switch (name) {
      case 'nagrev':
        hbc.appc.nagrevTemp.value = value;
        return;
      case 'viderzhka':
        hbc.appc.viderzhkaTime.value = value.truncate();
        return;
      case 'oxlazhdenie':
        hbc.appc.oxlazhdenieTemp.value = value;
        return;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text,
            style: TextStyle(
              fontSize: context.isPhone ? 16 : 18,
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w300,
              color: AppColors.colLightGrey,
            )),
        SizedBox(height: context.isPhone ? 10 : 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (var i in list)
              Container(
                  margin: const EdgeInsets.only(right: 30.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.colDarkGrey2,
                          side: const BorderSide(width: 1.0, color: Colors.white),
                          minimumSize: context.isPhone ? const Size(90, 36) : const Size(116, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: TextStyle(
                            fontSize: context.isPhone ? 16 : 20,
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w300,
                          )),
                      onPressed: () {
                        hbc.onPressed(i);
                        Get.find<InfoPaneController>(tag: name).changeMaxValue(hbc.pressedVal.value);
                        //Get.find<CustomSliderController>(tag: name).setRange(hbc.pressedVal.value.toDouble());
                        Get.find<CustomTimePickerController>(tag: name).setTimeSeconds(hbc.pressedVal.value.truncate());
                        setGlobalVar(hbc.pressedVal.value);
                      },
                      child: Text(i + label))),
          ],
        ),
      ],
    );
  }
}
