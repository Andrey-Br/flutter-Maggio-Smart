import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/appcontroller.dart';
import '../models/settings.dart';
import '../variables/colors.dart';
import '../widgets/snackbar.dart';

class ReceptBookController extends GetxController {
  final appc = Get.find<AppController>();
  final CustomSnackbarController sb = Get.put(CustomSnackbarController());
  final _listKey = GlobalKey<AnimatedListState>();
  List<AppSettings> _listItems = [];

  void _setRecept(int index) {
    appc.setSettings(index);
    Get.back();
  }

  Future<bool> _removeRecept(BuildContext context, int index) async {
    return await sb.showCenterDialog(
      title: "Удалить",
      text: "Вы точно хотите удалить запись?",
      primaryBtnText: 'msg_button_delete'.tr,
      secondaryBtnText: 'msg_button_cancel'.tr,
      soundPath: appc.isSoundEnable.value ? 'assets/audio/ding.mp3' : null,
      onPrimary: () {
        final removedItem = _listItems[index];
        _listItems.removeAt(index);
        appc.removeSettings(index);
        _listKey.currentState!.removeItem(
            index,
            (context, animation) => ReceptListItem(
                  item: removedItem,
                  animation: animation,
                  onDelete: () {},
                  onTap: () {},
                ),
            duration: const Duration(microseconds: 600));
      },
    );
  }

  AnimatedList _getReceptList() {
    _listItems = appc.settings
        .map((element) => AppSettings(
            receptName: element.receptName,
            selectNagrev: element.selectNagrev,
            selectViderzhka: element.selectViderzhka,
            selectOxlazhdenie: element.selectOxlazhdenie,
            selectMeshalka: element.selectMeshalka,
            nagrevTemp: element.nagrevTemp,
            nagrevPower: element.nagrevPower,
            viderzhkaTime: element.viderzhkaTime,
            oxlazhdenieTemp: element.oxlazhdenieTemp,
            mixerAuto: element.mixerAuto,
            mixerSpeed: element.mixerSpeed,
            mixerTimeAuto: element.mixerTimeAuto))
        .toList();

    return AnimatedList(
        key: _listKey,
        initialItemCount: _listItems.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index, animation) {
          return Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.horizontal,
              confirmDismiss: (DismissDirection direction) async {
                return await _removeRecept(context, index);
              },
              child: ReceptListItem(
                item: _listItems[index],
                animation: animation,
                onDelete: () => _removeRecept(context, index),
                onTap: () => _setRecept(index),
              ));
        });
  }
}

class ReceptBook extends StatelessWidget {
  final ReceptBookController rbc = Get.put(ReceptBookController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.colBackground,
        appBar: AppBar(
          leading: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/svg/button_back.svg',
                color: Colors.white,
                width: context.isPhone ? 28 : 36,
              ),
              onPressed: () {
                Get.back();
              }),
          leadingWidth: 70,
          toolbarHeight: context.isPhone ? 56 : 70,
          backgroundColor: AppColors.colTitle,
          title: Center(
            child: Text(
              'msg_settings_book'.tr,
              style: TextStyle(fontSize: context.isPhone ? 24 : 28, fontFamily: 'Rubik', fontWeight: FontWeight.w300),
            ),
          ),
        ),
        body: Padding(padding: EdgeInsets.all(context.isPhone ? 0 : 10), child: rbc._getReceptList()));
  }
}

class ReceptListItem extends StatelessWidget {
  final AppSettings item;
  final Animation<double> animation;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ReceptListItem({
    Key? key,
    required this.item,
    required this.animation,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: context.isPhone ? const EdgeInsets.only(top: 20, bottom: 8) : const EdgeInsets.only(top: 30, bottom: 8),
          child: Text(
            item.receptName,
            style: TextStyle(fontFamily: 'Rubik', fontSize: context.isPhone ? 18 : 22, color: AppColors.colWhite),
            overflow: TextOverflow.fade,
            softWrap: false,
          )),
      Card(
          color: AppColors.colDarkGrey4,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      splashColor: const Color.fromARGB(10, 255, 255, 255),
                      overlayColor: MaterialStateProperty.all(const Color.fromARGB(10, 255, 255, 255)),
                      onTap: onTap,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Flex(
                              direction: context.isLandscape ? Axis.horizontal : Axis.vertical,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: context.isLandscape ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                              children: [
                                Flex(
                                  direction: context.isLandscape ? Axis.vertical : Axis.horizontal,
                                  children: [
                                    Text(
                                      "${'msg_nagrev'.tr}:",
                                      style: TextStyle(
                                          fontFamily: 'Rubik',
                                          fontSize: context.isPhone ? 18 : 22,
                                          color: item.selectNagrev ? AppColors.colDarkGrey : AppColors.colDarkGrey2),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      "${item.nagrevTemp}${'msg_grad'.tr}",
                                      style: TextStyle(
                                          fontFamily: 'Rubik',
                                          fontSize: context.isPhone ? 22 : 28,
                                          color: item.selectNagrev ? AppColors.colNagrev : AppColors.colDarkGrey2),
                                    ),
                                  ],
                                ),
                                Flex(
                                  direction: context.isLandscape ? Axis.vertical : Axis.horizontal,
                                  children: [
                                    Text(
                                      "${'msg_viderzhka'.tr}:",
                                      style: TextStyle(
                                          fontFamily: 'Rubik',
                                          fontSize: context.isPhone ? 18 : 22,
                                          color: item.selectViderzhka ? AppColors.colDarkGrey : AppColors.colDarkGrey2),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      "${item.viderzhkaTime}${'msg_min'.tr}",
                                      style: TextStyle(
                                          fontFamily: 'Rubik',
                                          fontSize: context.isPhone ? 22 : 28,
                                          color: item.selectViderzhka ? AppColors.colViderzhka : AppColors.colDarkGrey2),
                                    ),
                                  ],
                                ),
                                Flex(
                                  direction: context.isLandscape ? Axis.vertical : Axis.horizontal,
                                  children: [
                                    Text(
                                      "${'msg_oxlazhdenie'.tr}:",
                                      style: TextStyle(
                                          fontFamily: 'Rubik',
                                          fontSize: context.isPhone ? 18 : 22,
                                          color: item.selectOxlazhdenie ? AppColors.colDarkGrey : AppColors.colDarkGrey2),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      "${item.oxlazhdenieTemp}${'msg_grad'.tr}",
                                      style: TextStyle(
                                          fontFamily: 'Rubik',
                                          fontSize: context.isPhone ? 22 : 28,
                                          color: item.selectOxlazhdenie ? AppColors.colOxlazhdenie : AppColors.colDarkGrey2),
                                    ),
                                  ],
                                ),
                                Flex(
                                  direction: context.isLandscape ? Axis.vertical : Axis.horizontal,
                                  children: [
                                    Text(
                                      "${'msg_meshalka'.tr}:",
                                      style: TextStyle(
                                          fontFamily: 'Rubik',
                                          fontSize: context.isPhone ? 18 : 22,
                                          color: item.selectMeshalka ? AppColors.colDarkGrey : AppColors.colDarkGrey2),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      "${item.mixerSpeed}% [${item.mixerTimeAuto}]",
                                      style: TextStyle(
                                          fontFamily: 'Rubik',
                                          fontSize: context.isPhone ? 22 : 28,
                                          color: item.selectMeshalka ? AppColors.colMeshalka : AppColors.colDarkGrey2),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                            // КРЕСТИК
                            Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: IconButton(
                                  icon: SvgPicture.asset(
                                    'assets/icons/svg/button_delete.svg',
                                    color: Colors.white,
                                    width: context.isPhone ? 22 : 30,
                                  ),
                                  onPressed: onDelete,
                                )),
                          ],
                        ),
                      )))))
    ]);
  }
}
