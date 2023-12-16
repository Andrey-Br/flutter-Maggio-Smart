import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'log_service.dart';

/* class BluStatus {
  BluStatus._();
  static const String wait = "BLU::Ожидание";
  static const String disconnect = "BLU::Отключено";
  static const String connect = "BLU::Подключено";
  static const String openPortError = "BLU::Ошибка открытия порта";
} */

class BluetoothService extends GetxService {
  final LogService log = Get.put(LogService());
  //var status = BluStatus.wait.obs;
  var serialData = [].obs;
  var isSelectBlue = false.obs;
  var isDiscovering = false.obs;
  var deviceAddress = "".obs;
  var deviceName = "".obs;

  Rx<BluetoothState> bluetoothState = BluetoothState.UNKNOWN.obs;
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> bluetoothDiscoveryResult = [];
  BluetoothDevice? _bluetoothDevice;
  BluetoothConnection? _bluetoothConnection;

  @override
  Future<BluetoothService> onInit() async {
    super.onInit();

    FlutterBluetoothSerial.instance.state.then((state) {
      bluetoothState.value = state;
      //bluetoothState.refresh();
/* 
      if (state.stringValue == 'STATE_ON') {
        isSelectBlue.value = true;
        startDiscovery();
      } else if (state.stringValue == 'STATE_OFF') {
        isSelectBlue.value = false;
      }
*/
    });

    Future.doWhile(() async {
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    }).then((_) {
      FlutterBluetoothSerial.instance.address.then((address) {
        deviceAddress.value = address!;
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      deviceName.value = name!;
    });

    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      bluetoothState.value = state;
      //bluetoothState.refresh();
/*       if (state.stringValue == 'STATE_ON') {
        isSelectBlue.value = true;
        log.printLog('Bluetooth ВКЛ');
        startDiscovery();
      }*/
      if (state.stringValue == 'STATE_OFF') {
        toogleBTonDevice(false);
      }
    });

    return this;
  }

  @override
  void onClose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _streamSubscription!.cancel();

    if (isConnected()) {
      _bluetoothConnection!.dispose();
      _bluetoothConnection = null;
    }
    btConnect(false);
    log.printLog("BT on Close\n");
    super.onClose();
  }

  void restartDiscovery() {
    bluetoothDiscoveryResult.clear();
    startDiscovery();
  }

///////////////////////////////
  void startDiscovery() async {
    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
      _streamSubscription = null;
    }

    _streamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      isDiscovering.value = true;
      bluetoothDiscoveryResult.add(r);
      log.printLog("Найдено: ${r.device.name} rssi: ${r.rssi}");
      if (r.device.name?.substring(0, 6) == "MAGGIO") {
        _bluetoothDevice = r.device;
        log.printLog("Найдено: ${r.device.name} rssi: ${r.rssi}");
        FlutterBluetoothSerial.instance.cancelDiscovery();
      }
    });
    _streamSubscription!.onDone(() {
      isDiscovering.value = false;
      if (_bluetoothDevice != null) {
        log.printLog("BT:: Попытка соединения с MAGGIO...");
        btConnect(_bluetoothDevice);
      } else {
        toogleBTonDevice(false);
        log.printLog("BT:: MAGGIO не найдено!");
      }
    });
  }

////////////////////////////////
  Future<bool> btConnect(device) async {
    serialData.clear();

    if (device == null) {
      _bluetoothDevice = null;
      log.printLog("BT ==>> Отключено\n");
      return true;
    } else {
      try {
        _bluetoothConnection = await BluetoothConnection.toAddress(_bluetoothDevice!.address);
        log.printLog('Соединение с ${_bluetoothDevice!.name} (${_bluetoothDevice!.address}) по Bluetooth...');
        bluWrite("OK");

        _bluetoothConnection!.input!.listen((Uint8List response) {
          String dataString = String.fromCharCodes(response, 0, response.length - 2);
          if (dataString.isNotEmpty) {
            serialData.add(dataString);
          }
        }).onDone(() {
          toogleBTonDevice(false);
          log.printLog('BT::Соединение пропало!');
        });
      } catch (error) {
        isSelectBlue.value = false;
        log.printLog('BT::Ошибка соединения => $error');
      }
    }
    return true;
  }

  Future<void> togleSystemBluetooth(bool value) async {
    if (value) {
      try {
        await FlutterBluetoothSerial.instance.requestEnable();
      } catch (e) {
        log.printLog("BT::requestEnable\n $e");
      }
    } else {
      try {
        await FlutterBluetoothSerial.instance.requestDisable();
      } catch (e) {
        log.printLog("BT::requestDisable\n $e");
      }
    }
  }

  Future<void> toogleBTonDevice(bool value) async {
    if (value) {
      if (bluetoothState.value.stringValue == 'STATE_OFF') {
        try {
          await togleSystemBluetooth(value);
          startDiscovery();
          isSelectBlue.value = true;
          log.printLog('Bluetooth ВКЛ');
        } catch (error) {
          isSelectBlue.value = false;
          log.printLog("BT::Ошибка togleSystemBluetooth\n $error");
        }
      } else if (bluetoothState.value.stringValue == 'STATE_ON') {
        startDiscovery();
        isSelectBlue.value = true;
        log.printLog('Bluetooth ВКЛ');
      }
    } else {
      isSelectBlue.value = false;
      isDiscovering.value = false;

      if (isConnected()) {
        _bluetoothConnection!.dispose();
        _bluetoothConnection = null;
      }
      btConnect(null);
      log.printLog('Bluetooth ВЫКЛ');
    }
  }

  bool isConnected() {
    return _bluetoothConnection != null && _bluetoothConnection!.isConnected;
  }

  Future<void> bluWrite(String msg) async {
    msg = msg.trim();
    if (msg.isNotEmpty) {
      try {
        Uint8List data = Uint8List.fromList("$msg\r\n".codeUnits);
        _bluetoothConnection!.output.add(data);
        await _bluetoothConnection!.output.allSent;
        log.printLog("BT::Отправлено: $msg");
        return;
      } catch (e) {
        log.printLog("BT::Ошибка отправки команды!\n$e");
      }
    }
  }
}
