import 'dart:async';
import 'dart:typed_data';

import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:get/get.dart';
import 'log_service.dart';

class UsbStatus {
  UsbStatus._();
  static const String wait = "USB::Ожидание";
  static const String disconnect = "USB::Отключено";
  static const String connect = "USB::Подключено";
  static const String openPortError = "USB::Ошибка открытия порта";
}

class UsbService extends GetxService {
  final LogService log = Get.put(LogService());
  UsbPort? _port;
  var status = UsbStatus.wait.obs;
  var serialData = [].obs;
  List<String> _ports = [];

  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbDevice? _device;

  Future<bool> _connectTo(device) async {
    serialData.clear();

    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction!.dispose();
      _transaction = null;
    }

    if (_port != null) {
      _port!.close();
      _port = null;
    }

    if (device == null) {
      _device = null;
      status.value = UsbStatus.disconnect;
      log.printLog(UsbStatus.disconnect);
      return true;
    }

    try {
      _port = await device.create();
      // You can customize your driver and the port number
      //_port = await device.create(UsbSerial.CP21xx, 4);
    } catch (_) {
      log.printLog("Ранен!");
      return true;
    }

    if (await (_port!.open()) != true) {
      status.value = UsbStatus.openPortError;
      log.printLog(UsbStatus.openPortError);
      return false;
    }

    _device = device;

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    //await _port!.connect();

    _transaction = Transaction.stringTerminated(_port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));

    _subscription = _transaction!.stream.listen((String response) {
      response.isNotEmpty ? serialData.add(response) : {};
      //if (serialData.length > 20) {
      //  serialData.removeAt(0);
      //}
    });

    status.value = UsbStatus.connect;
    usbWrite("OK");
    log.printLog(UsbStatus.connect);
    return true;
  }

  void _getPorts() async {
    _ports = [];
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (!devices.contains(_device)) {
      _connectTo(null);
    }

    for (var device in devices) {
      String port = "deviceName: ${device.deviceName} "
          "productName: ${device.productName} "
          "manufacturerName: ${device.manufacturerName} "
          "vid: ${device.vid} "
          "pid: ${device.pid}";
      log.printLog(port);
      _ports.add(port);

      _connectTo(_device == device ? null : device).then((res) {
        //_getPorts();
      });
    }
  }

  //@override
  Future<UsbService> init() async {
    super.onInit();

    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      _getPorts();
    });

    _getPorts();
    return this;
  }

  @override
  void onClose() {
    _connectTo(null);
    super.onClose();
  }

  Future<void> usbWrite(String msg) async {
    try {
      if (msg.isNotEmpty) {
        Uint8List data = Uint8List.fromList(msg.codeUnits);
        if (_port != null) {
          await _port?.write(data);
          log.printLog("USB::Отправлено: $msg");
        }
      }
    } catch (e) {
      log.printLog("USB::Ошибка отправки команды!\n$e");
    }
  }

/*   void readFromUsb() {
    if (serialData.isNotEmpty) {
      log.printLog("USB::Получено: $serialData \n");
      return;
    }
    log.printLog("USB::Ничего не прочитано!\n");
  } */

/*   void statusUsb() {
    _ports.isNotEmpty ? log.printLog("Доступные USB порты: $_ports\n") : log.printLog("Нет доступных USB устройств");
    log.printLog("USB::Статус: ${status.value}");
    log.printLog("USB::Порт: ${_port.toString()}");
  } */
}
