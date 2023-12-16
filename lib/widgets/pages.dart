import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../variables/colors.dart';
import '../controllers/appcontroller.dart';
import 'slider.dart';
import 'timepicker.dart';
import 'infopane.dart';
import 'select_btn.dart';

/*  СТРАНИЦА НАГРЕВ  */
class AppPageNagrev extends StatefulWidget {
  AppPageNagrev({Key? key}) : super(key: key);

  @override
  State<AppPageNagrev> createState() => _AppPageNagrevState();
}

class _AppPageNagrevState extends State<AppPageNagrev> with AutomaticKeepAliveClientMixin<AppPageNagrev> {
  final appc = Get.find<AppController>();

  @override
  bool get wantKeepAlive => true;
  int? _value = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(context.isPhone ? 10 : 20),
        child: Column(children: [
          Obx(() => InfoPane(
                name: 'nagrev',
                activeTitle: 'msg_milk_temp'.tr,
                activeColor: AppColors.colNagrev,
                minValue: 1,
                maxValue: appc.nagrevTemp.value, // > appc.currentTempMilk.value ? appc.nagrevTemp.value : appc.currentTempMilk.value.round(),
                currentValue: appc.currentTempMilk.value,
                label: ' ${'msg_grad'.tr}',
              )),
          Obx(() => CustomSlider(
              text: 'msg_nagrev_temp'.tr,
              label: 'msg_grad'.tr,
              name: 'nagrev',
              activeColor: AppColors.colNagrev,
              min: 10, //appc.currentTempMilk.value.round(),
              max: 100,
              div: 0.5,
              round: false,
              value: appc.nagrevTemp.value,
              onChanged: (value) {
                appc.changeTempNagrev(double.parse((value).toStringAsFixed(1)));
              })),
          SizedBox(
            height: context.isPhone ? 0 : 20,
          ),
          Obx(() => SelectButton(
              text: 'msg_nagrev_power'.tr,
              list: const ["1", "2", "3"],
              value: appc.nagrevPower.value - 1,
              onChanged: (value) {
                appc.changeTempPower(value);
              })),
        ]));
  }
}

/*  СТРАНИЦА ВЫДЕРЖКА  */
class AppPageViderzhka extends StatefulWidget {
  AppPageViderzhka({Key? key}) : super(key: key);

  @override
  State<AppPageViderzhka> createState() => _AppPageViderzhkaState();
}

class _AppPageViderzhkaState extends State<AppPageViderzhka> with AutomaticKeepAliveClientMixin<AppPageViderzhka> {
  final appc = Get.find<AppController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(context.isPhone ? 10 : 20),
        child: Column(children: [
          Obx(() => InfoPane(
                name: 'viderzhka',
                activeTitle: 'msg_viderzhka_time_left'.tr,
                activeColor: AppColors.colViderzhka,
                minValue: 0,
                maxValue: appc.viderzhkaTime.value.toDouble(),
                currentValue: appc.currentViderzhka.value.toDouble(),
                label: 'msg_min'.tr,
                reverse: true,
              )),
/*
          Obx(() => CustomSlider(
              text: 'msg_viderzhka_time'.tr,
              label: 'msg_min'.tr,
              name: 'viderzhka',
              activeColor: AppColors.colViderzhka,
              min: 1,
              max: 180,
              value: appc.viderzhkaTime.value,
              onChanged: (value) {
                appc.changeViderzhka(value);
              })),
 */
          CustomTimePicker(
              name: 'viderzhka',
              text: 'msg_viderzhka_time'.tr,
              value: appc.viderzhkaTime.value,
              onChanged: (value) {
                appc.changeViderzhka(value);
              }),
/*           SizedBox(
              height: context.isPhone
                  ? context.isLandscape
                      ? 10
                      : 20
                  : 20),
          if (appc.getViderzhka4List().isNotEmpty)
            Obx(() => HelperButton(
                  text: 'msg_nedavno'.tr,
                  label: 'msg_min'.tr,
                  name: 'viderzhka',
                  list: appc.getViderzhka4List(),
                )) */
        ]));
  }
}

/*  СТРАНИЦА ОХЛАЖДЕНИЕ  */
class AppPageOxlazhdenie extends StatefulWidget {
  AppPageOxlazhdenie({Key? key}) : super(key: key);

  @override
  State<AppPageOxlazhdenie> createState() => _AppPageOxlazhdenieState();
}

class _AppPageOxlazhdenieState extends State<AppPageOxlazhdenie> with AutomaticKeepAliveClientMixin<AppPageOxlazhdenie> {
  final appc = Get.find<AppController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(context.isPhone ? 10 : 20),
        child: Column(children: [
          Obx(() => InfoPane(
                name: 'oxlazhdenie',
                activeTitle: 'msg_milk_temp'.tr,
                activeColor: AppColors.colOxlazhdenie,
                minValue: 1,
                maxValue: appc.oxlazhdenieTemp.value,
                currentValue: appc.currentTempMilk.value,
                label: ' ${'msg_grad'.tr}',
                reverse: true,
              )),
          Obx(() => CustomSlider(
              text: 'msg_oxlazhdenie_temp'.tr,
              label: 'msg_grad'.tr,
              name: 'oxlazhdenie',
              activeColor: AppColors.colOxlazhdenie,
              min: 1,
              max: 100,
              div: 0.5,
              round: false,
              value: appc.oxlazhdenieTemp.value,
              onChanged: (value) {
                appc.changeTempOxlazhdenie(double.parse((value).toStringAsFixed(1)));
              })),
/*           SizedBox(
              height: context.isPhone
                  ? context.isLandscape
                      ? 10
                      : 20
                  : 20),
          if (appc.getOxlazhdenie4List().isNotEmpty)
            Obx(() => HelperButton(
                  name: 'oxlazhdenie',
                  text: 'msg_nedavno'.tr,
                  label: 'msg_grad'.tr,
                  list: appc.getOxlazhdenie4List(),
                )) */
        ]));
  }
}

/*  СТРАНИЦА НАГРЕВ  */
class AppPagePodderzhanie extends StatefulWidget {
  AppPagePodderzhanie({Key? key}) : super(key: key);

  @override
  State<AppPagePodderzhanie> createState() => _AppPagePodderzhanieState();
}

class _AppPagePodderzhanieState extends State<AppPagePodderzhanie> with AutomaticKeepAliveClientMixin<AppPagePodderzhanie> {
  final appc = Get.find<AppController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(context.isPhone ? 10 : 20),
        child: Column(children: [
          Obx(() => InfoPane(
                name: 'podderzhanie',
                activeTitle: 'msg_milk_temp'.tr,
                activeColor: AppColors.colNagrev,
                minValue: 1,
                maxValue: appc.podderzhanieTemp.value,
                currentValue: appc.currentTempMilk.value,
                label: ' ${'msg_grad'.tr}',
              )),
          Obx(() => CustomSlider(
              text: 'msg_podderzhanie_temp'.tr,
              label: 'msg_grad'.tr,
              name: 'podderzhanie',
              activeColor: AppColors.colNagrev,
              min: 10, //appc.currentTempMilk.value.round(),
              max: 100,
              div: 0.5,
              round: false,
              value: appc.podderzhanieTemp.value,
              onChanged: (value) {
                appc.changeTempPodderzhanie(double.parse((value).toStringAsFixed(1)));
              })),
        ]));
  }
}

/*  СТРАНИЦА МЕШАЛКА  */
class AppPageMeshalka extends StatefulWidget {
  AppPageMeshalka({Key? key}) : super(key: key);

  @override
  State<AppPageMeshalka> createState() => _AppPageMeshalkaState();
}

class _AppPageMeshalkaState extends State<AppPageMeshalka> with AutomaticKeepAliveClientMixin<AppPageMeshalka> {
  final appc = Get.find<AppController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(context.isPhone ? 10 : 20),
        child: Column(children: [
          SizedBox(height: context.isPhone ? 0 : 20),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text('msg_meshalka_auto'.tr.toUpperCase(),
                style: TextStyle(
                  fontSize: context.isPhone ? 15 : 18,
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w300,
                  color: AppColors.colLightGrey,
                )),
            const SizedBox(width: 40),
            Transform.scale(
              scale: context.isPhone ? 1.2 : 1.7,
              child: Obx(() => Switch.adaptive(
                    value: appc.mixerAuto.value,
                    onChanged: (value) {
                      appc.togleMixerAuto(value);
                    },
                    activeColor: AppColors.colWhite,
                    activeTrackColor: AppColors.colViderzhka,
                    inactiveTrackColor: AppColors.colDarkGrey2,
                    inactiveThumbColor: AppColors.colDarkGrey,
                    splashRadius: 20,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )),
            ),
          ]),
          SizedBox(height: context.isPhone ? 0 : 20),
          Obx(() => SelectButton(
              text: 'msg_meshalka_direction'.tr,
              activeColor: AppColors.colMeshalka,
              inActiveColor: AppColors.colLightGrey,
              list: ['msg_meshalka_left'.tr, 'msg_meshalka_right'.tr],
              disable: appc.mixerAuto.value,
              value: appc.mixerDirection.value,
              onChanged: (value) {
                appc.changeMixerDirection(value);
              })),
          SizedBox(height: context.isPhone ? 10 : 20),
          Obx(() => CustomSlider(
              text: 'msg_meshalka_speed'.tr,
              label: ' %',
              name: 'mix_speed',
              activeColor: AppColors.colMeshalka,
              min: 0,
              max: 100,
              divisions: 10,
              value: appc.mixerSpeed.value.toDouble(),
              onChanged: (value) {
                appc.changeMixerSpeed(value.truncate());
              })),
          Obx(() => CustomSlider(
              text: 'msg_meshalka_time'.tr,
              label: 'msg_sec'.tr,
              name: 'mix_time',
              activeColor: AppColors.colMeshalka,
              min: 0,
              max: 120,
              divisions: 12,
              value: appc.mixerTimeAuto.value.toDouble(),
              onChanged: (value) {
                appc.changeMixerTimeAuto(value.truncate());
              }))
        ]));
  }
}
