// ignore_for_file: prefer_const_constructors
// ignore: prefer_const_literals_to_create_immutables

import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'services/storage_service.dart';
import 'services/usb_service.dart';
import 'services/blu_service.dart';
import 'variables/messages.dart';

//import 'home_bt.dart';
import 'services/binding.dart';
import 'package:wakelock/wakelock.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'controllers/appcontroller.dart';
import 'variables/colors.dart';
import 'screens/screen_save_dialog.dart';
import 'screens/screen_timer_dialog.dart';
import 'screens/screen_list_recepts.dart';
import 'screens/screen_settings.dart';
import 'widgets/tabbuttons.dart';
import 'widgets/snackbar.dart';
//import 'widgets/animation.dart';

void main() async {
  await GetStorage.init();
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => UsbService().init());
  await Get.putAsync(() => BluetoothService().onInit());

  Wakelock.enable();

  WidgetsFlutterBinding.ensureInitialized();
  // Альбомный вид
  //SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  // Скрыть верхний и нижний тулбар
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);

  runApp(GetMaterialApp(
    translations: Messages(),
    locale: Locale('ru', 'RU'),
    fallbackLocale: Locale('en', 'US'),
    debugShowCheckedModeBanner: false,
    initialBinding: AppBinding(),
    initialRoute: '/',
    getPages: [
      GetPage(name: '/', page: () => Home(), binding: AppBinding()),
      GetPage(name: '/mainsettings', page: () => MainSettings()),
    ],
    home: Home(),
    //home: BTPage2(),
  ));
}

class Home extends GetResponsiveView<AppController> {
  Home({Key? key}) : super(key: key);

  final ScrollController _scrollController = ScrollController();
  final CustomSnackbarController sb = Get.put(CustomSnackbarController());
  final node = FocusNode();
  final fnode = FocusScopeNode();

  @override
  Widget build(BuildContext context) {
    controller.appContext = context;
    return WillPopScope(
        onWillPop: () {
          return sb.showCenterDialog(
            title: "Выход",
            text: 'msg_notify_quit'.tr,
            primaryBtnText: 'msg_button_exit'.tr,
            secondaryBtnText: 'msg_button_cancel'.tr,
            soundPath: controller.isSoundEnable.value ? 'assets/audio/ding.mp3' : null,
            onPrimary: () {
              Navigator.of(context).pop(true);
            },
          );
        },
        child: Scaffold(
            body: GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: Stack(children: [
                  Container(
                      color: AppColors.colBackground,
                      child: DefaultTextStyle(
                          style: const TextStyle(
                              fontSize: 24, fontFamily: 'Rubik', fontWeight: FontWeight.w300, decoration: TextDecoration.none, color: Colors.white),
                          child: Column(
                            children: [
                              topStatusBar(context),
                              CustomTabs(),
                              bottomNavigate(context),
                            ],
                          ))),
                  //SizedBox(height: context.isPortrait ? 90 : 0)
                  //bottomLogConsole(context),
                ]))));
  }

// Строка состояния сверху
  Widget topStatusBar(BuildContext context) {
    return SizedBox(
      height: context.isLandscape
          ? context.isPhone
              ? 34
              : 40
          : 65,
      child: Container(
          color: AppColors.colInfoPane,
          child: Padding(
              padding: context.isPhone ? EdgeInsets.fromLTRB(10, 5, 10, 5) : EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: Flex(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                verticalDirection: VerticalDirection.up,
                crossAxisAlignment: CrossAxisAlignment.center,
                direction: context.isLandscape ? Axis.horizontal : Axis.vertical,
                children: [
/*                   Row(children: [
                    Text("${'msg_step'.tr}    ", style: const TextStyle(fontSize: 15, color: AppColors.colLightGrey)),
                    Obx(() => Text(controller.currentStepToString(controller.currentStep.value),
                        style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 255, 255, 255))))
                  ]), */

                  Obx(() => Text(
                        controller.getTime(controller.commonTimer.value),
                        style: TextStyle(
                          color: AppColors.colLightGrey,
                          fontSize: 18,
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.w300,
                        ),
                      )),
                  SizedBox(width: 20),
                  Obx(() => controller.currentReceptName.value != ""
                      ? Row(children: [
                          Text("${'msg_recept_select'.tr}    ", style: const TextStyle(fontSize: 15, color: AppColors.colLightGrey)),
                          Text(controller.currentReceptName.value, style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 255, 255, 255)))
                        ])
                      : SizedBox(width: 0)),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      SizedBox(
                          height: context.isPhone ? 18 : 22,
                          width: context.isPhone ? 18 : 22,
                          child: SvgPicture.asset(
                            'assets/icons/svg/button_timer.svg',
                            color: AppColors.colWhite,
                            alignment: Alignment.center,
                          )),
                      SizedBox(width: 10),
                      Obx(() => Text(
                            controller.getTime(controller.appTimer.value),
                            style: TextStyle(
                              color: AppColors.colWhite,
                              fontSize: context.isPhone ? 18 : 20,
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w300,
                            ),
                          )),
                    ]),
/*                     SizedBox(width: 30),
                    Row(children: [
                      Obx(() => SizedBox(
                          height: context.isPhone ? 20 : 26,
                          width: context.isPhone ? 20 : 26,
                          child: SvgPicture.asset(
                            'assets/icons/svg/icon_red_button.svg',
                            color: controller.isRedButtonPressed.value ? AppColors.colButtonStart : AppColors.colDarkGrey2,
                            alignment: Alignment.center,
                          ))),
                      SizedBox(width: 10),
                      Obx(() => SizedBox(
                          height: context.isPhone ? 20 : 26,
                          width: context.isPhone ? 20 : 26,
                          child: SvgPicture.asset(
                            'assets/icons/svg/icon_water.svg',
                            color: controller.isWaterFill.value ? AppColors.colCurrOxlazhdenie : AppColors.colDarkGrey2,
                            alignment: Alignment.center,
                          ))),
                      SizedBox(width: 10),
                      Obx(() => SizedBox(
                          height: context.isPhone ? 20 : 26,
                          width: context.isPhone ? 22 : 28,
                          child: SvgPicture.asset(
                            'assets/icons/svg/icon_mixer.svg',
                            color: controller.selectMeshalka.value ? AppColors.colMeshalka : AppColors.colDarkGrey2,
                            alignment: Alignment.center,
                          ))),
                    ]), */
                    SizedBox(width: 30),
                    Row(children: [
                      Row(children: [
                        Obx(() => SizedBox(
                            height: 20,
                            width: 10,
                            child: SvgPicture.asset(
                              'assets/icons/svg/icon_arrow.svg',
                              color:
                                  (controller.currentStep.value == 1 || controller.currentStep.value == 2) ? AppColors.colButtonStart : AppColors.colDarkGrey2,
                              alignment: Alignment.center,
                            ))),
                        Obx(() => SizedBox(
                              height: 20,
                              width: 10,
                              child: Transform.rotate(
                                  angle: math.pi,
                                  child: SvgPicture.asset(
                                    'assets/icons/svg/icon_arrow.svg',
                                    color: controller.currentStep.value == 3 ? AppColors.colCurrOxlazhdenie : AppColors.colDarkGrey2,
                                    alignment: Alignment.center,
                                  )),
                            )),
                        SizedBox(width: 8),
                        Obx(() =>
                            Text("${controller.currentTempMilk.value} ${'msg_grad'.tr}", style: const TextStyle(fontSize: 18, color: AppColors.colNagrev))),
                        Obx(() => Text(" [ ${controller.currentTempWater.value} ${'msg_grad'.tr} ]",
                            style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 100, 165, 201)))),
                      ]),
                      SizedBox(width: 30),
                      Obx(() => SizedBox(
                            height: context.isPhone ? 22 : 30,
                            width: context.isPhone ? 22 : 30,
                            child: SvgPicture.asset(
                              'assets/icons/svg/icon_usb.svg',
                              color: controller.isUSBConnected.value ? AppColors.colButtonStart : AppColors.colDarkGrey2,
                              alignment: Alignment.center,
                            ),
                          )),
                      Obx(() => SizedBox(
                          height: context.isPhone ? 22 : 30,
                          width: context.isPhone ? 22 : 30,
                          child: SvgPicture.asset(
                            'assets/icons/svg/icon_blu.svg',
                            color: controller.isBLUConnected.value ? AppColors.colCurrOxlazhdenie : AppColors.colDarkGrey2,
                            alignment: Alignment.center,
                          ))),
                    ]),
                  ])
                ],
              ))),
    );
  }

// Кнопка СТАРТ и иконки снизу
  Widget bottomNavigate(BuildContext context) {
    return Container(
        /* decoration: const BoxDecoration(
            //color: AppColors.colInfoPane,
            boxShadow: [
              BoxShadow(color: Colors.black, offset: Offset(10, 0)),
              BoxShadow(color: Colors.black, offset: Offset(-10, 0)),
              BoxShadow(color: AppColors.colInfoPane, blurRadius: 5, spreadRadius: -5)
            ]), */
        color: AppColors.colInfoPane,
        padding: context.isPhone ? EdgeInsets.fromLTRB(10, 0, 10, 0) : EdgeInsets.fromLTRB(16, 12, 16, 12),
        margin: EdgeInsets.only(top: 20),
        child: SizedBox(
            height: context.isPhone ? 60 : 70,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Material(
                  color: Colors.transparent,
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/svg/button_book.svg',
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(15),
                      iconSize: context.isPhone ? 28 : 38,
                      highlightColor: Color.fromARGB(40, 255, 255, 255),
                      splashColor: Color.fromARGB(40, 255, 255, 255),
                      onPressed: () {
                        Get.to(() => ReceptBook(), duration: Duration(milliseconds: 500), transition: Transition.fadeIn
                            //curve: Curves.bounceInOut
                            );
                      })),
              Material(
                  color: Colors.transparent,
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/svg/button_save.svg',
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(15),
                      iconSize: context.isPhone ? 28 : 38,
                      onPressed: () {
                        showSaveDialog(context);
                      })),
              SizedBox(width: 20),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colButtonStart,
                      minimumSize: context.isPhone
                          ? const Size(150, 40)
                          : context.isLandscape
                              ? const Size(230, 56)
                              : const Size(200, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: TextStyle(
                        fontSize: context.isPhone ? 28 : 36,
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w500,
                      )),
                  onPressed: () async {
                    controller.onPressedStartBtn();
                  },
                  child: Obx(() => Text("${controller.startBtnText}"))),
              SizedBox(width: 20),
              Material(
                  color: Colors.transparent,
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/svg/button_timer.svg',
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(15),
                      iconSize: context.isPhone ? 28 : 38,
                      onPressed: () {
                        showTimerDialog(context);
                      })),
              Material(
                  color: Colors.transparent,
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/svg/button_settings.svg',
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(15),
                      iconSize: context.isPhone ? 28 : 38,
                      onPressed: () {
                        Get.to(() => MainSettings(),
                            //binding: SettingsBinding(),
                            duration: Duration(milliseconds: 500),
                            transition: Transition.fadeIn);
                      })),
            ])));
  }

// Консоль для логов снизу
  Widget bottomLogConsole(BuildContext context) {
    return Positioned(
        bottom: 0,
        left: context.isPortrait ? 0 : Get.width / 2 - 225,
        child: SizedBox(
            height: context.isPhone
                ? context.isPortrait
                    ? 100
                    : 80
                : 100,
            width: context.isPortrait ? Get.width : 400,
            child: Stack(
              children: [
                Container(
                    padding: const EdgeInsets.all(5),
                    color: Color.fromARGB(90, 0, 0, 0),
                    child: Obx(
                      () => ListView(
                          controller: _scrollController,
                          children: controller.log.logText.map((msg) => Text(msg, style: const TextStyle(fontSize: 11, color: Colors.white))).toList()),
                    )),
              ],
            )));
  }
}

/*
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_widgets.dart';

void main() {
  runApp(const FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBluePlus.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return const FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context).primaryTextTheme.subtitle2?.copyWith(color: Colors.white),
            ),
            ElevatedButton(
              child: const Text('TURN ON'),
              onPressed: Platform.isAndroid ? () => FlutterBluePlus.instance.turnOn() : null,
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
        actions: [
          ElevatedButton(
            child: const Text('TURN OFF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: Platform.isAndroid ? () => FlutterBluePlus.instance.turnOff() : null,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(const Duration(seconds: 2)).asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map((d) => ListTile(
                            title: Text(d.name),
                            subtitle: Text(d.id.toString()),
                            trailing: StreamBuilder<BluetoothDeviceState>(
                              stream: d.state,
                              initialData: BluetoothDeviceState.disconnected,
                              builder: (c, snapshot) {
                                if (snapshot.data == BluetoothDeviceState.connected) {
                                  return ElevatedButton(
                                    child: const Text('OPEN'),
                                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => DeviceScreen(device: d))),
                                  );
                                }
                                return Text(snapshot.data.toString());
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBluePlus.instance.scanResults,
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map(
                        (r) => ScanResultTile(
                          result: r,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                            r.device.connect();
                            return DeviceScreen(device: r.device);
                          })),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBluePlus.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: const Icon(Icons.stop),
              onPressed: () => FlutterBluePlus.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: const Icon(Icons.search), onPressed: () => FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 8)));
          }
        },
      ),
    );
  }
}

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  List<int> _getRandomBytes() {
    final math = Random();
    return [math.nextInt(255), math.nextInt(255), math.nextInt(255), math.nextInt(255)];
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map(
                  (c) => CharacteristicTile(
                    characteristic: c,
                    onReadPressed: () => c.read(),
                    onWritePressed: () async {
                      await c.write(_getRandomBytes(), withoutResponse: true);
                      await c.read();
                    },
                    onNotificationPressed: () async {
                      await c.setNotifyValue(!c.isNotifying);
                      await c.read();
                    },
                    descriptorTiles: c.descriptors
                        .map(
                          (d) => DescriptorTile(
                            descriptor: d,
                            onReadPressed: () => d.read(),
                            onWritePressed: () => d.write(_getRandomBytes()),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return TextButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context).primaryTextTheme.button?.copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    snapshot.data == BluetoothDeviceState.connected ? const Icon(Icons.bluetooth_connected) : const Icon(Icons.bluetooth_disabled),
                    snapshot.data == BluetoothDeviceState.connected
                        ? StreamBuilder<int>(
                            stream: rssiStream(),
                            builder: (context, snapshot) {
                              return Text(snapshot.hasData ? '${snapshot.data}dBm' : '', style: Theme.of(context).textTheme.caption);
                            })
                        : Text('', style: Theme.of(context).textTheme.caption),
                  ],
                ),
                title: Text('Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data! ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => device.discoverServices(),
                      ),
                      const IconButton(
                        icon: SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            StreamBuilder<int>(
              stream: device.mtu,
              initialData: 0,
              builder: (c, snapshot) => ListTile(
                title: const Text('MTU Size'),
                subtitle: Text('${snapshot.data} bytes'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => device.requestMtu(223),
                ),
              ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: const [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Stream<int> rssiStream() async* {
    var isConnected = true;
    final subscription = device.state.listen((state) {
      isConnected = state == BluetoothDeviceState.connected;
    });
    while (isConnected) {
      yield await device.readRssi();
      await Future.delayed(const Duration(seconds: 1));
    }
    subscription.cancel();
    // Device disconnected, stopping RSSI stream
  }
}
*/