// ignore_for_file: prefer_const_constructors
// ignore: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maggio_smart/widgets/animation.dart';
import '../controllers/appcontroller.dart';
import '../variables/colors.dart';
import 'pages.dart';

class CustomTabsController extends GetxController {
  var selectedPage = 0.obs;
  late final PageController _pageController;
  final appc = Get.find<AppController>();

  @override
  void onInit() {
    super.onInit();
    _pageController = PageController();
  }

  @override
  void onClose() {
    _pageController.dispose();
    super.onClose();
  }

  isChecked(int tabNum) {
    switch (tabNum) {
      case 0:
        return appc.selectNagrev.value;
      case 1:
        return appc.selectViderzhka.value;
      case 2:
        return appc.selectOxlazhdenie.value;
      case 3:
        return appc.selectPodderzhanie.value;
      case 4:
        return appc.selectMeshalka.value;
      default:
    }
  }

  isDisabled(int tabNum) {
    switch (tabNum) {
      case 0:
        return appc.blockNagrev.value;
      case 1:
        return appc.blockViderzhka.value;
      case 2:
        return appc.blockOxlazhdenie.value;
      case 3:
        return appc.blockPodderzhanie.value;
      case 4:
        return false;
      default:
    }
  }

  void checkedTab(int tabNum) {
    switch (tabNum) {
      case 0:
        appc.onSelectNagrev();
        break;
      case 1:
        appc.onSelectViderzhka();
        break;
      case 2:
        appc.onSelectOxlazhdenie();
        break;
      case 3:
        appc.onSelectPodderzhanie();
        break;
      case 4:
        appc.onSelectMeshalka();
        break;
      default:
    }
  }

  void changePage(int pageNum) {
    selectedPage.value = pageNum;
    //_pageController.animateToPage(pageNum, duration: Duration(milliseconds: 500), curve: Curves.easeInOutQuint);
    _pageController.jumpToPage(pageNum);
  }

  List<Color> selColor() {
    switch (selectedPage.value) {
      case 0:
        return AppColors.colButtonNagrev;
      case 1:
        return AppColors.colButtonViderzhka;
      case 2:
        return AppColors.colButtonOxlazhdenie;
      case 3:
        return AppColors.colButtonNagrev;
      default:
        return AppColors.colButtonMeshalka;
    }
  }

  Color currColor() {
    switch (selectedPage.value) {
      case 0:
        return AppColors.colCurrNagrev;
      case 1:
        return AppColors.colCurrViderzhka;
      case 2:
        return AppColors.colCurrOxlazhdenie;
      case 3:
        return AppColors.colCurrNagrev;
      default:
        return AppColors.colCurrMeshalka;
    }
  }

  Color pageColor(int page) {
    switch (page) {
      case 0:
        return AppColors.colCurrNagrev;
      case 1:
        return AppColors.colCurrViderzhka;
      case 2:
        return AppColors.colCurrOxlazhdenie;
      case 3:
        return AppColors.colCurrNagrev;
      default:
        return AppColors.colCurrMeshalka;
    }
  }

  String iconPath(int pageNumber) {
    switch (pageNumber) {
      case 0:
        return 'assets/icons/svg/icon_work_nagrev.svg';
      case 1:
        return 'assets/icons/svg/icon_work_viderzhka.svg';
      case 2:
        return 'assets/icons/svg/icon_work_oxlazhdenie.svg';
      case 3:
        return 'assets/icons/svg/icon_work_nagrev.svg';
      default:
        return 'assets/icons/svg/icon_work_mixer.svg';
    }
  }

  String imgPath(int pageNumber) {
    switch (pageNumber) {
      case 0:
        return 'assets/images/nagrev.png';
      case 1:
        return 'assets/images/viderzhka.png';
      case 2:
        return 'assets/images/oxlazhdenie.png';
      case 3:
        return 'assets/images/nagrev.png';
      default:
        return 'assets/images/meshalka.png';
    }
  }

  String tabCurrentVar(int pageNumber) {
    switch (pageNumber) {
      case 0:
        return "${appc.nagrevTemp} ${'msg_grad'.tr}";
      case 1:
        return appc.getTime(appc.viderzhkaTime.truncate());
      case 2:
        return "${appc.oxlazhdenieTemp} ${'msg_grad'.tr}";
      case 3:
        return "${appc.podderzhanieTemp} ${'msg_grad'.tr}";
      default:
        return "${appc.mixerSpeed} %, ${appc.mixerTimeAuto} ${'msg_sec'.tr}";
    }
  }
}

class CustomTabs extends StatelessWidget {
  CustomTabs({Key? key}) : super(key: key);
  final CustomTabsController ctc = Get.put(CustomTabsController());
  final appc = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Flex(
      direction: context.isLandscape ? Axis.horizontal : Axis.vertical,
      children: [
        Expanded(
            child: PageView(
          onPageChanged: (int page) {
            ctc.selectedPage.value = page;
          },
          controller: ctc._pageController,
          scrollDirection: context.isLandscape ? Axis.vertical : Axis.horizontal,
          children: [
            AppPageNagrev(),
            AppPageViderzhka(),
            AppPageOxlazhdenie(),
            AppPagePodderzhanie(),
            AppPageMeshalka(),
          ],
        )),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: context.isPhone ? 10 : 20),
            child: context.isPortrait ? renderPortrait(context) : renderLandscape(context))
      ],
    ));
  }

  Widget renderLandscape(BuildContext context) {
    return SizedBox(
      width: context.isPhone ? 230 : 306,
      child: Padding(
        padding: EdgeInsets.only(top: context.isPhone ? 10 : 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                Obx(() => TabButton(
                      context,
                      'msg_nagrev'.tr,
                      appc.selectNagrev.value,
                      0,
                    )),
                SizedBox(width: 5),
                Obx(() => TabButton(
                      context,
                      'msg_viderzhka'.tr,
                      appc.selectViderzhka.value,
                      1,
                    )),
              ],
            ),
            SizedBox(height: 5),
            Row(children: [
              Obx(() => TabButton(
                    context,
                    'msg_oxlazhdenie'.tr,
                    appc.selectOxlazhdenie.value,
                    2,
                  )),
              SizedBox(width: 5),
              Obx(() => TabButton(
                    context,
                    'msg_podderzhanie'.tr,
                    appc.selectPodderzhanie.value,
                    3,
                  )),
            ]),
            SizedBox(height: 5),
            Obx(() => TabButton(
                  context,
                  'msg_meshalka'.tr,
                  appc.selectMeshalka.value,
                  4,
                ))
          ],
        ),
      ),
    );
  }

  Widget renderPortrait(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      //mainAxisSize: MainAxisSize.max,
      children: [
        Row(mainAxisSize: MainAxisSize.max, children: [
          Obx(() => TabButton(
                context,
                'msg_nagrev'.tr,
                appc.selectNagrev.value,
                0,
              )),
          SizedBox(width: context.isPhone ? 5 : 15),
          Obx(() => TabButton(
                context,
                'msg_viderzhka'.tr,
                appc.selectViderzhka.value,
                1,
              )),
        ]),
        SizedBox(height: context.isPhone ? 5 : 15),
        Row(mainAxisSize: MainAxisSize.max, children: [
          Obx(() => TabButton(
                context,
                'msg_oxlazhdenie'.tr,
                appc.selectOxlazhdenie.value,
                2,
              )),
          SizedBox(width: context.isPhone ? 5 : 15),
          Obx(() => TabButton(
                context,
                'msg_podderzhanie'.tr,
                appc.selectPodderzhanie.value,
                3,
              ))
        ]),
        SizedBox(height: context.isPhone ? 5 : 15),
        Row(mainAxisSize: MainAxisSize.max, children: [
          Obx(() => TabButton(
                context,
                'msg_meshalka'.tr,
                appc.selectMeshalka.value,
                4,
              ))
        ])
      ],
    );
  }

  Widget TabButton(BuildContext context, String text, bool val, int pageNumber) {
    return Expanded(
        child: GestureDetector(
            onTap: () => {
                  if (!ctc.isDisabled(pageNumber))
                    {
                      ctc.selectedPage.value == pageNumber ? {ctc.checkedTab(pageNumber)} : {},
                    },
                  ctc.changePage(pageNumber)
                },
            child: Stack(alignment: AlignmentDirectional.centerStart, children: [
              // Кнопка
              Container(
                  height: context.isLandscape ? 150 : 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      alignment: Alignment.bottomRight,
                      image: AssetImage(ctc.imgPath(pageNumber)),
                      fit: BoxFit.scaleDown,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                      colors: ctc.selectedPage.value == pageNumber ? ctc.selColor() : AppColors.colButtonDefault,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                    //boxShadow: [BoxShadow(color: currColor(), blurRadius: ctc._animation.value, spreadRadius: ctc._animation.value)]
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                text.toUpperCase(),
                                style: TextStyle(
                                    fontSize: context.isPhone ? 15 : 16,
                                    color: (ctc.selectedPage.value == pageNumber) && (pageNumber == 0 || pageNumber == 3) ? Colors.black : Colors.white),
                              ),
                            ],
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              ctc.tabCurrentVar(pageNumber),
                              style: TextStyle(
                                  fontSize: context.isPhone ? 18 : 28,
                                  color: (ctc.selectedPage.value == pageNumber) && (pageNumber == 0 || pageNumber == 3) ? Colors.black : Colors.white),
                            ),
                          ]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Transform.scale(
                                scale: context.isPhone ? 1.2 : 1.5,
                                child: Switch.adaptive(
                                  value: val,
                                  onChanged: (value) {
                                    !ctc.isDisabled(pageNumber) ? ctc.checkedTab(pageNumber) : null;
                                  },
                                  activeColor: !ctc.isDisabled(pageNumber) ? AppColors.colWhite : Color.fromARGB(255, 155, 162, 172),
                                  activeTrackColor: !ctc.isDisabled(pageNumber) ? Color.fromARGB(255, 87, 226, 0) : Color.fromARGB(255, 121, 128, 141),
                                  inactiveThumbColor: !ctc.isDisabled(pageNumber) ? Color.fromARGB(255, 255, 255, 255) : Color.fromARGB(255, 155, 162, 172),
                                  inactiveTrackColor: !ctc.isDisabled(pageNumber) ? Color.fromARGB(255, 255, 134, 134) : Color.fromARGB(255, 121, 128, 141),
                                  splashRadius: 20,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                            ],
                          ),
                        ],
                      )),
                    ],
                  )),

              // Активная точка
              Obx(() => Positioned(
                  bottom: 5,
                  right: 5,
                  child: PulseAnimation(
                    body: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: (ctc.appc.currentStep.value - 1) != pageNumber
                              ? Colors.transparent
                              : ctc.selectedPage.value == pageNumber
                                  ? AppColors.colWhite
                                  : ctc.pageColor(pageNumber),
                          shape: BoxShape.circle,
                        )),
                  ))),
              if (pageNumber == 4)
                Obx(() => Positioned(
                    bottom: 5,
                    right: 5,
                    child: PulseAnimation(
                      body: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: !ctc.appc.selectMeshalka.value
                                ? Colors.transparent
                                : ctc.selectedPage.value == pageNumber
                                    ? AppColors.colWhite
                                    : ctc.pageColor(pageNumber),
                            shape: BoxShape.circle,
                          )),
                    ))),
            ])));
  }
}

/* class TabButton extends StatelessWidget {
  final CustomTabsController ctc = Get.put(CustomTabsController());
  TabButton({Key? key, required this.text, required this.val, required this.pageNumber}) : super(key: key);

  final String text;
  final bool val;
  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GestureDetector(
            onTap: () => {
                  if (!ctc.isDisabled(pageNumber))
                    {
                      ctc.selectedPage.value == pageNumber ? {ctc.checkedTab(pageNumber)} : {},
                    },
                  ctc.changePage(pageNumber)
                },
            child: Stack(alignment: AlignmentDirectional.centerStart, children: [
              // Уголок на кнопке
/*                   if (context.isLandscape)
                    Container(
                      margin: EdgeInsets.only(bottom: context.isPhone ? 7 : 17),
                      transform: Matrix4.rotationZ(3.14 / 4),
                      width: context.isPhone ? 15 : 20,
                      height: context.isPhone ? 15 : 20,
                      decoration: BoxDecoration(
                        color: ctc.selectedPage.value == pageNumber ? ctc.currColor() : Colors.transparent,
                      ),
                    ), */
              // Кнопка
              Obx(() => Container(
                  height: context.isLandscape ? 150 : 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      alignment: Alignment.bottomRight,
                      image: AssetImage(ctc.imgPath(pageNumber)),
                      fit: BoxFit.scaleDown,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                      colors: ctc.selectedPage.value == pageNumber ? ctc.selColor() : AppColors.colButtonDefault,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                    //boxShadow: [BoxShadow(color: currColor(), blurRadius: ctc._animation.value, spreadRadius: ctc._animation.value)]
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
/*                           Padding(
                            padding: context.isPhone ? const EdgeInsets.fromLTRB(5, 0, 15, 0) : const EdgeInsets.fromLTRB(10, 0, 20, 0),
                            child: SizedBox(
                              width: context.isPhone ? 36 : 44,
                              child: SvgPicture.asset(
                                ctc.iconPath(pageNumber),
                                semanticsLabel: text,
                                color: (ctc.selectedPage.value == pageNumber) && (pageNumber == 0 || pageNumber == 3) ? Colors.black : Colors.white,
                                alignment: Alignment.center,
                              ),
                            ),
                          ), */
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  text.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: context.isPhone ? 15 : 16,
                                      color: (ctc.selectedPage.value == pageNumber) && (pageNumber == 0 || pageNumber == 3) ? Colors.black : Colors.white),
                                ),
                              ],
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(
                                ctc.tabCurrentVar(pageNumber),
                                style: TextStyle(
                                    fontSize: context.isPhone ? 18 : 28,
                                    color: (ctc.selectedPage.value == pageNumber) && (pageNumber == 0 || pageNumber == 3) ? Colors.black : Colors.white),
                              ),
                            ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Transform.scale(
                                  scale: context.isPhone ? 1.2 : 1.5,
                                  child: Switch.adaptive(
                                    value: val,
                                    onChanged: (value) {
                                      !ctc.isDisabled(pageNumber) ? ctc.checkedTab(pageNumber) : {};
                                    },
                                    activeColor: AppColors.colWhite,
                                    activeTrackColor: Color.fromARGB(255, 87, 226, 0),
                                    inactiveTrackColor: Color.fromARGB(255, 134, 142, 158),
                                    inactiveThumbColor: Color.fromARGB(255, 176, 182, 194),
                                    splashRadius: 20,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ))),

              // Активная точка
              Obx(() => Positioned(
                  bottom: 5,
                  right: 5,
                  child: PulseAnimation(
                    body: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: (ctc.appc.currentStep.value - 1) != pageNumber
                              ? Colors.transparent
                              : ctc.selectedPage.value == pageNumber
                                  ? AppColors.colWhite
                                  : ctc.pageColor(pageNumber),
                          shape: BoxShape.circle,
                        )),
                  ))),
              if (pageNumber == 4)
                Obx(() => Positioned(
                    bottom: 5,
                    right: 5,
                    child: PulseAnimation(
                      body: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: !ctc.appc.selectMeshalka.value
                                ? Colors.transparent
                                : ctc.selectedPage.value == pageNumber
                                    ? AppColors.colWhite
                                    : Color.fromARGB(255, 207, 0, 253),
                            shape: BoxShape.circle,
                          )),
                    ))),
            ])));
  } */

  // Чекбокс на кнопке
/*   Widget checkBox(BuildContext context) {
    return GestureDetector(
      onTap: () => !ctc.isDisabled(pageNumber) ? ctc.checkedTab(pageNumber) : {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastLinearToSlowEaseIn,
        decoration: BoxDecoration(
            color:
                ctc.isChecked(pageNumber) ? (ctc.isDisabled(pageNumber) ? Color.fromARGB(255, 223, 223, 223) : Color.fromARGB(255, 255, 230, 0)) : Colors.white,
            border: ctc.isChecked(pageNumber) ? null : Border.all(color: AppColors.colNagrev, width: context.isPhone ? 1 : 2)),
        width: context.isPhone ? 28 : 38,
        height: context.isPhone ? 28 : 38,
        padding: const EdgeInsets.all(5.0),
        child: ctc.isChecked(pageNumber)
            ? SvgPicture.asset(
                'assets/icons/svg/icon_check.svg',
                color: ctc.isDisabled(pageNumber) ? Color.fromARGB(255, 179, 179, 179) : Colors.black,
              )
            : null,
      ),
    );
  } */

