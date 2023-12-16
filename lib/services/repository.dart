import '../models/settings.dart';
import 'provider.dart';

class SettingsRepository {
  AppProvider appProvider;
  SettingsRepository({required this.appProvider});

  List<AppSettings> readSettings() => appProvider.readSettings();
  void writeSettings(List<AppSettings> settings) => appProvider.writeSettings(settings);
}
