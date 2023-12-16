import 'package:get/get.dart';
import '../services/log_service.dart';
import '../services/usb_service.dart';
import '../services/blu_service.dart';
import '../controllers/appcontroller.dart';
import '../widgets/slider.dart';
import '../widgets/timepicker.dart';

import '../widgets/infopane.dart';
import 'provider.dart';
import 'repository.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<LogService>(LogService());
    Get.put<UsbService>(UsbService());
    Get.put<BluetoothService>(BluetoothService());

    Get.put<AppController>(AppController(repository: SettingsRepository(appProvider: AppProvider())));

    Get.put<CustomSliderController>(CustomSliderController(), tag: 'nagrev');
    Get.put<CustomSliderController>(CustomSliderController(), tag: 'power');
    Get.put<CustomSliderController>(CustomSliderController(), tag: 'oxlazhdenie');
    Get.put<CustomSliderController>(CustomSliderController(), tag: 'podderzhanie');
    Get.put<CustomSliderController>(CustomSliderController(), tag: 'mix_speed');
    Get.put<CustomSliderController>(CustomSliderController(), tag: 'mix_time');

    Get.put<CustomTimePickerController>(CustomTimePickerController(), tag: 'viderzhka');
    Get.put<CustomTimePickerController>(CustomTimePickerController(), tag: 'app_timer');

    Get.put<InfoPaneController>(InfoPaneController(), tag: 'nagrev');
    Get.put<InfoPaneController>(InfoPaneController(), tag: 'viderzhka');
    Get.put<InfoPaneController>(InfoPaneController(), tag: 'oxlazhdenie');
    Get.put<InfoPaneController>(InfoPaneController(), tag: 'podderzhanie');
  }
}

/* class SettingsBinding implements Bindings {
  @override
  void dependencies() {
    //Get.put<CustomSwitchController>(CustomSwitchController(), tag: 'bt_switch');
    //Get.create<CustomSwitchController>(() => CustomSwitchController(), tag: 'bt_switch');
  }
}
 */