import 'package:equatable/equatable.dart';

// Настройки приложения
class AppSettings extends Equatable {
  String receptName;
  bool selectNagrev;
  bool selectViderzhka;
  bool selectOxlazhdenie;
  bool selectMeshalka;
  double nagrevTemp;
  int nagrevPower;
  int viderzhkaTime;
  double oxlazhdenieTemp;
  bool mixerAuto;
  int mixerSpeed;
  int mixerTimeAuto;

  AppSettings(
      {required this.receptName,
      required this.selectNagrev,
      required this.selectViderzhka,
      required this.selectOxlazhdenie,
      required this.selectMeshalka,
      required this.nagrevTemp,
      required this.nagrevPower,
      required this.viderzhkaTime,
      required this.oxlazhdenieTemp,
      required this.mixerAuto,
      required this.mixerSpeed,
      required this.mixerTimeAuto});

  AppSettings copyWith(
          {String? receptName,
          bool? selectNagrev,
          bool? selectViderzhka,
          bool? selectOxlazhdenie,
          bool? selectMeshalka,
          double? nagrevTemp,
          int? nagrevPower,
          int? viderzhkaTime,
          double? oxlazhdenieTemp,
          bool? mixerAuto,
          int? mixerSpeed,
          int? mixerTimeAuto}) =>
      AppSettings(
          receptName: receptName ?? this.receptName,
          selectNagrev: selectNagrev ?? this.selectNagrev,
          selectViderzhka: selectViderzhka ?? this.selectViderzhka,
          selectOxlazhdenie: selectOxlazhdenie ?? this.selectOxlazhdenie,
          selectMeshalka: selectMeshalka ?? this.selectMeshalka,
          nagrevTemp: nagrevTemp ?? this.nagrevTemp,
          nagrevPower: nagrevPower ?? this.nagrevPower,
          viderzhkaTime: viderzhkaTime ?? this.viderzhkaTime,
          oxlazhdenieTemp: oxlazhdenieTemp ?? this.oxlazhdenieTemp,
          mixerAuto: mixerAuto ?? this.mixerAuto,
          mixerSpeed: mixerSpeed ?? this.mixerSpeed,
          mixerTimeAuto: mixerTimeAuto ?? this.mixerTimeAuto);

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
      receptName: json['receptName'],
      selectNagrev: json['selectNagrev'],
      selectViderzhka: json['selectViderzhka'],
      selectOxlazhdenie: json['selectOxlazhdenie'],
      selectMeshalka: json['selectMeshalka'],
      nagrevTemp: json['nagrevTemp'],
      nagrevPower: json['nagrevPower'],
      viderzhkaTime: json['viderzhkaTime'],
      oxlazhdenieTemp: json['oxlazhdenieTemp'],
      mixerAuto: json['mixerAuto'],
      mixerSpeed: json['mixerSpeed'],
      mixerTimeAuto: json['mixerTimeAuto']);

  Map<String, dynamic> toJson() => {
        "receptName": receptName,
        "selectNagrev": selectNagrev,
        "selectViderzhka": selectViderzhka,
        "selectOxlazhdenie": selectOxlazhdenie,
        "selectMeshalka": selectMeshalka,
        "nagrevTemp": nagrevTemp,
        "nagrevPower": nagrevPower,
        "viderzhkaTime": viderzhkaTime,
        "oxlazhdenieTemp": oxlazhdenieTemp,
        "mixerAuto": mixerAuto,
        "mixerSpeed": mixerSpeed,
        "mixerTimeAuto": mixerTimeAuto
      };

  @override
  List<Object?> get props => [
        receptName,
        selectNagrev,
        selectViderzhka,
        selectOxlazhdenie,
        selectMeshalka,
        nagrevTemp,
        nagrevPower,
        viderzhkaTime,
        oxlazhdenieTemp,
        mixerAuto,
        mixerSpeed,
        mixerTimeAuto
      ];
}

// Настройки рецепта
class ReceptSettings extends Equatable {
  String receptName;
  bool selectNagrev;
  bool selectViderzhka;
  bool selectOxlazhdenie;
  bool selectMeshalka;
  double nagrevTemp;
  int nagrevPower;
  int viderzhkaTime;
  double oxlazhdenieTemp;
  bool mixerAuto;
  int mixerSpeed;
  int mixerTimeAuto;

  ReceptSettings(
      {required this.receptName,
      required this.selectNagrev,
      required this.selectViderzhka,
      required this.selectOxlazhdenie,
      required this.selectMeshalka,
      required this.nagrevTemp,
      required this.nagrevPower,
      required this.viderzhkaTime,
      required this.oxlazhdenieTemp,
      required this.mixerAuto,
      required this.mixerSpeed,
      required this.mixerTimeAuto});

  ReceptSettings copyWith(
          {String? receptName,
          bool? selectNagrev,
          bool? selectViderzhka,
          bool? selectOxlazhdenie,
          bool? selectMeshalka,
          double? nagrevTemp,
          int? nagrevPower,
          int? viderzhkaTime,
          double? oxlazhdenieTemp,
          bool? mixerAuto,
          int? mixerSpeed,
          int? mixerTimeAuto}) =>
      ReceptSettings(
          receptName: receptName ?? this.receptName,
          selectNagrev: selectNagrev ?? this.selectNagrev,
          selectViderzhka: selectViderzhka ?? this.selectViderzhka,
          selectOxlazhdenie: selectOxlazhdenie ?? this.selectOxlazhdenie,
          selectMeshalka: selectMeshalka ?? this.selectMeshalka,
          nagrevTemp: nagrevTemp ?? this.nagrevTemp,
          nagrevPower: nagrevPower ?? this.nagrevPower,
          viderzhkaTime: viderzhkaTime ?? this.viderzhkaTime,
          oxlazhdenieTemp: oxlazhdenieTemp ?? this.oxlazhdenieTemp,
          mixerAuto: mixerAuto ?? this.mixerAuto,
          mixerSpeed: mixerSpeed ?? this.mixerSpeed,
          mixerTimeAuto: mixerTimeAuto ?? this.mixerTimeAuto);

  factory ReceptSettings.fromJson(Map<String, dynamic> json) => ReceptSettings(
      receptName: json['receptName'],
      selectNagrev: json['selectNagrev'],
      selectViderzhka: json['selectViderzhka'],
      selectOxlazhdenie: json['selectOxlazhdenie'],
      selectMeshalka: json['selectMeshalka'],
      nagrevTemp: json['nagrevTemp'],
      nagrevPower: json['nagrevPower'],
      viderzhkaTime: json['viderzhkaTime'],
      oxlazhdenieTemp: json['oxlazhdenieTemp'],
      mixerAuto: json['mixerAuto'],
      mixerSpeed: json['mixerSpeed'],
      mixerTimeAuto: json['mixerTimeAuto']);

  Map<String, dynamic> toJson() => {
        "receptName": receptName,
        "selectNagrev": selectNagrev,
        "selectViderzhka": selectViderzhka,
        "selectOxlazhdenie": selectOxlazhdenie,
        "selectMeshalka": selectMeshalka,
        "nagrevTemp": nagrevTemp,
        "nagrevPower": nagrevPower,
        "viderzhkaTime": viderzhkaTime,
        "oxlazhdenieTemp": oxlazhdenieTemp,
        "mixerAuto": mixerAuto,
        "mixerSpeed": mixerSpeed,
        "mixerTimeAuto": mixerTimeAuto
      };

  @override
  // TODO: implement props
  List<Object?> get props => [
        receptName,
        selectNagrev,
        selectViderzhka,
        selectOxlazhdenie,
        selectMeshalka,
        nagrevTemp,
        nagrevPower,
        viderzhkaTime,
        oxlazhdenieTemp,
        mixerAuto,
        mixerSpeed,
        mixerTimeAuto
      ];
}
