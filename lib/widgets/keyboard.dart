// ignore: constant_identifier_names
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Virtual keyboard actions.
enum VirtualKeyboardKeyAction { Backspace, Confirm, Shift, Space, Lang }

enum VirtualKeyboardKeyType { Action, String }

enum VirtualKeyboardType { Numeric, AlphanumericEN, AlphanumericRU }

/// Virtual Keyboard key
class VirtualKeyboardKey {
  final String text;
  final String capsText;
  final VirtualKeyboardKeyType keyType;
  final VirtualKeyboardKeyAction? action;

  VirtualKeyboardKey({this.text = '', this.capsText = '', required this.keyType, this.action});
}

/// Keys for Virtual Keyboard's rows.
const List<List> _keyRowsRU = [
  ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
  ['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х'],
  ['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э'],
  ['я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'ъ', 'б', 'ю'],
  []
];

/// Keys for Virtual Keyboard's rows.
const List<List> _keyRowsEN = [
  ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
  ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
  ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', '-'],
  ['z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.'],
  []
];

/// Keys for Virtual Keyboard's rows.
const List<List> _keyRowsNumeric = [
  ['1', '2', '3', '4', '5'],
  ['6', '7', '8', '9', '0', '.'],
];

BoxDecoration keyDecoration = BoxDecoration(
    color: const Color.fromARGB(255, 73, 74, 85),
    border: Border.all(color: const Color.fromARGB(255, 107, 108, 124), width: 1.0),
    borderRadius: BorderRadius.circular(8));

/// Возвращает список объектов цифровой клавиатуры.
List<VirtualKeyboardKey> _getKeyboardRowKeysNumeric(rowNum) {
  // Создает объекты для каждой строки.
  return List.generate(_keyRowsNumeric[rowNum].length, (int keyNum) {
    // Get key string value.
    String key = _keyRowsNumeric[rowNum][keyNum];

    // Создает и возвращает новый объект.
    return VirtualKeyboardKey(
      text: key,
      capsText: key.toUpperCase(),
      keyType: VirtualKeyboardKeyType.String,
    );
  });
}

/// Возвращает список объектов `VirtualKeyboardKey`.
List<VirtualKeyboardKey> _getKeyboardRowKeys(rowNum, String lang) {
  return List.generate(lang == "RU" ? _keyRowsRU[rowNum].length : _keyRowsEN[rowNum].length, (int keyNum) {
    String key = lang == "RU" ? _keyRowsRU[rowNum][keyNum] : _keyRowsEN[rowNum][keyNum];

    return VirtualKeyboardKey(
      text: key,
      capsText: key.toUpperCase(),
      keyType: VirtualKeyboardKeyType.String,
    );
  });
}

/// Возвращает список строк VirtualKeyboard с объектами `VirtualKeyboardKey`.
List<List<VirtualKeyboardKey>> _getKeyboardRows(String lang) {
  return List.generate(_keyRowsRU.length, (int rowNum) {
    List<VirtualKeyboardKey> rowKeys = [];

    switch (rowNum) {
      case 0:
        rowKeys = _getKeyboardRowKeys(rowNum, lang);
        rowKeys.add(VirtualKeyboardKey(keyType: VirtualKeyboardKeyType.Action, action: VirtualKeyboardKeyAction.Backspace));
        break;
      case 1:
        rowKeys = _getKeyboardRowKeys(rowNum, lang);
        break;
      case 2:
        rowKeys = _getKeyboardRowKeys(rowNum, lang);
        break;
      case 3:
        rowKeys = _getKeyboardRowKeys(rowNum, lang);
        rowKeys.add(VirtualKeyboardKey(keyType: VirtualKeyboardKeyType.Action, action: VirtualKeyboardKeyAction.Lang));
        break;
      case 4:
        rowKeys = _getKeyboardRowKeys(rowNum, lang);
        rowKeys.add(VirtualKeyboardKey(keyType: VirtualKeyboardKeyType.Action, action: VirtualKeyboardKeyAction.Space, text: ' ', capsText: ' '));
        break;
      default:
        rowKeys = _getKeyboardRowKeys(rowNum, lang);
    }
    return rowKeys;
  });
}

/// Возвращает список строк VirtualKeyboard с объектами `VirtualKeyboardKey`.
List<List<VirtualKeyboardKey>> _getKeyboardRowsNumeric() {
  return List.generate(_keyRowsNumeric.length, (int rowNum) {
    List<VirtualKeyboardKey> rowKeys = [];

    switch (rowNum) {
      case 0:
        rowKeys = _getKeyboardRowKeysNumeric(rowNum);
        //rowKeys.addAll(_getKeyboardRowKeysNumeric(rowNum));
        rowKeys.add(VirtualKeyboardKey(keyType: VirtualKeyboardKeyType.Action, action: VirtualKeyboardKeyAction.Confirm));
        break;
      default:
        rowKeys = _getKeyboardRowKeysNumeric(rowNum);
        //rowKeys.addAll(_getKeyboardRowKeysNumeric(rowNum));
        rowKeys.add(VirtualKeyboardKey(keyType: VirtualKeyboardKeyType.Action, action: VirtualKeyboardKeyAction.Backspace));
    }
    return rowKeys;
  });
}

/// ВИДЖЕТ виртуальной клавиатуры
class VirtualKeyboard extends StatefulWidget {
  final VirtualKeyboardType type;
  final Function onKeyPress;
  final double height;
  final Color textColor;
  final double fontSize;
  final bool alwaysCaps;

  const VirtualKeyboard(
      {Key? key, required this.type, required this.onKeyPress, this.height = 300, this.textColor = Colors.black, this.fontSize = 22, this.alwaysCaps = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VirtualKeyboardState();
  }
}

/// Holds the state for Virtual Keyboard class.
class _VirtualKeyboardState extends State<VirtualKeyboard> {
  late VirtualKeyboardType type;
  late Function onKeyPress;
  late double height;
  late Color textColor;
  late double fontSize;
  late bool alwaysCaps;
  late TextStyle textStyle;

  bool isShiftEnabled = false;
  bool isRUKeyboard = true;

  @override
  void didUpdateWidget(Widget oldWidget) {
    setState(() {
      type = widget.type;
      onKeyPress = widget.onKeyPress;
      height = widget.height;
      textColor = widget.textColor;
      fontSize = widget.fontSize;
      alwaysCaps = widget.alwaysCaps;
      textStyle = TextStyle(
        fontSize: fontSize,
        color: textColor,
      );
    });
  }

  @override
  void initState() {
    super.initState();

    type = widget.type;
    onKeyPress = widget.onKeyPress;
    height = widget.height;
    textColor = widget.textColor;
    fontSize = widget.fontSize;
    alwaysCaps = widget.alwaysCaps;
    textStyle = TextStyle(
      fontSize: fontSize,
      color: textColor,
      fontFamily: 'Rubik',
      fontWeight: FontWeight.w300,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {},
        child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(200, 13, 13, 13),
            ),
            height: height,
            width: MediaQuery.of(context).size.width,
            child: ClipRRect(
                child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _rows(),
              ),
            ))));
  }

  /// Возвращает строки для клавиатуры.
  List<Widget> _rows() {
    // Get the keyboard Rows
    List<List<VirtualKeyboardKey>> keyboardRows = type == VirtualKeyboardType.Numeric
        ? _getKeyboardRowsNumeric()
        : (type == VirtualKeyboardType.AlphanumericRU ? _getKeyboardRows("RU") : _getKeyboardRows("EN"));

    // Генерирует строку с кнопками
    List<Widget> rows = List.generate(keyboardRows.length, (int rowNum) {
      return Material(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,

          // Генерирует кнопки клавиатуры
          children: List.generate(
            keyboardRows[rowNum].length,
            (int keyNum) {
              VirtualKeyboardKey virtualKeyboardKey = keyboardRows[rowNum][keyNum];
              Widget keyWidget;

              switch (virtualKeyboardKey.keyType) {
                case VirtualKeyboardKeyType.String:
                  keyWidget = _keyboardDefaultKey(virtualKeyboardKey);
                  break;
                case VirtualKeyboardKeyType.Action:
                  keyWidget = _keyboardDefaultActionKey(virtualKeyboardKey);
                  break;
              }
              return keyWidget;
            },
          ),
        ),
      );
    });
    return rows;
  }

  /// Разрешает длинное нажатие.
  late bool longPress;

  /// Создает вид Обычной кнопки по умолчанию.
  Widget _keyboardDefaultKey(VirtualKeyboardKey key) {
    return Flexible(
        child: ConstrainedBox(
            constraints: type != VirtualKeyboardType.Numeric ? const BoxConstraints(minWidth: 500) : const BoxConstraints(minWidth: 100),
            child: Container(
                margin: const EdgeInsets.all(3),
                height: 52,
                child: GestureDetector(
                    onLongPress: () {
                      longPress = true;
                      Timer.periodic(const Duration(milliseconds: 50), (timer) {
                        if (longPress) {
                          onKeyPress(key);
                        } else {
                          timer.cancel();
                        }
                      });
                    },
                    onLongPressUp: () {
                      longPress = false;
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        onKeyPress(key);
                      },
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.center,
                        backgroundColor: const Color.fromARGB(255, 73, 74, 85),
                        padding: const EdgeInsets.all(5),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Color.fromARGB(255, 107, 108, 124), width: 1.0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(alwaysCaps ? key.capsText : (isShiftEnabled ? key.capsText : key.text), style: textStyle),
                    )))));
  }

  /// Создает вид кнопки Action по умолчанию.
  Widget _keyboardDefaultActionKey(VirtualKeyboardKey key) {
    late Widget actionKeyIcon;

    switch (key.action) {
      case VirtualKeyboardKeyAction.Backspace:
        actionKeyIcon = SvgPicture.asset('assets/icons/svg/key_backspace.svg', width: 30, color: textColor);
        break;
      case VirtualKeyboardKeyAction.Space:
        actionKeyIcon = SvgPicture.asset('assets/icons/svg/key_spacebar.svg', width: 35, color: textColor);
        break;
      case VirtualKeyboardKeyAction.Lang:
        actionKeyIcon = SvgPicture.asset('assets/icons/svg/key_lang.svg', width: 30, color: textColor);
        break;
      case VirtualKeyboardKeyAction.Confirm:
        actionKeyIcon = SvgPicture.asset('assets/icons/svg/icon_check.svg', width: 30, color: textColor);
        break;
      default:
    }

    return Flexible(
        child: ConstrainedBox(
            constraints: type != VirtualKeyboardType.Numeric ? const BoxConstraints(minWidth: 500) : const BoxConstraints(minWidth: 100),
            child: Container(
                margin: const EdgeInsets.all(3),
                height: 52,
                child: GestureDetector(
                    onLongPress: () {
                      longPress = true;
                      if (key.action != VirtualKeyboardKeyAction.Lang) {
                        Timer.periodic(const Duration(milliseconds: 50), (timer) {
                          if (longPress) {
                            onKeyPress(key);
                          } else {
                            timer.cancel();
                          }
                        });
                      } else {
                        onKeyPress(key);
                      }
                    },
                    onLongPressUp: () {
                      longPress = false;
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        onKeyPress(key);
                      },
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.center,
                        backgroundColor:
                            key.action != VirtualKeyboardKeyAction.Confirm ? const Color.fromARGB(255, 73, 74, 85) : Color.fromARGB(255, 66, 124, 59),
                        padding: const EdgeInsets.all(5),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: key.action != VirtualKeyboardKeyAction.Confirm
                                  ? const Color.fromARGB(255, 107, 108, 124)
                                  : const Color.fromARGB(255, 87, 175, 75),
                              width: 1.0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: actionKeyIcon,
                    )))));
  }
}
