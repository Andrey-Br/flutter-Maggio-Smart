class Cmd {
  Cmd._();

  // Прочитать состояние (Android)
  //  TM212_TW213_WE_RR_TN111_MS0_MA0_ST0_HS800_TS0_KS0

  //  TM = t молока
  //  TW = t воды
  //  WE = Нет воды в рубашке      //   WF = Рубашка заполнена
  //  RR = Красная кнопка отжата   //   RP = Красная кнопка нажата
  //  MS = Скорость мешалки
  //  MA = Включить автореверс (1-вкл, 0-выкл)
  //  ST = Текущий этап
  //  HS = Нагрев (0-выкл)
  //  TS = Выдержка (0-выкл)
  //  KS = Охлаждение (0-выкл)
  //
  //
  static const String state = "ST"; // Текущий этап

  // Мешалка (Android)
  static const String mf = "MF"; // Выключить миксер
  static const String ma = "MA"; // Включить автореверс. MA***** - Время в мс
  static const String ms = "MS"; // Скорость мешалки. MS** %
  static const String md = "MD"; // Направление вращения влево(MD0)/вправо(MD1)
  static const String mr = "MR"; // Включить миксер в одну сторону
  static const String mc = "MC"; // Сменить направление

  // Температура (Board)
  static const String tm = "TM"; // t молока TM***, TM315 -> t = 31.5
  static const String tw = "TW"; // t воды TW***, TW315 -> t = 31.5

  // Включение ТЭНов (Board)
  static const String tn = "TN"; // ТЭН 1 Включен(TN100) / ТЭН 2 Включен(TN110) / ТЭН 3 Включен(TN111)

  // Вода в рубашке (Board)
  static const String we = "WE"; // Нет воды в рубашке
  static const String wf = "WF"; // Вода в рубашке есть

  // Красная кнопка (Board)
  static const String rp = "RP"; // Красная кнопка нажата
  static const String rr = "RR"; // Красная кнопка отжата

  // Приготовление (Android)
  static const String ko = "KO"; // Открыть клапан с холодной водой
  static const String kc = "KC"; // Закрыть клапан с холодной водой

  static const String tm1 = "T+"; // Включить нагрев (ручной режим)
  static const String tm0 = "T-"; // Отключить нагрев (ручной режим)

  // Приготовление - Авто (Android)
  static const String hs = "HS"; // Нагрев до HS***, Если HS0 - отключить
  static const String hd = "HD"; // Нагрев до HD*** и держать бесконечно, Если HD0 - отключить
  static const String ts = "TS"; // Выдержка TS*** секунд, Если TS0 - отключить
  static const String tl = "TL"; // Выдержки осталось TL*** секунд
  static const String ks = "KS"; // Охлаждение до KS***, Если KS0 - отключить

  static const String rc = "RC"; // Начать автоматическое приготовление
  static const String rs = "RS"; // Закончить автоматическое приготовление

  // Оповещения (Board)
  static const String dh = "DH"; // Молоко нагрето до нужной температуры
  static const String dd = "DD"; // Выдержка закончена
  static const String dc = "DC"; // Охлаждение завершено
  static const String da = "DA"; // Приготовление всего завершенно

  // Энкодер A (Board)
  static const String ac = "AC"; // Обычное нажатие
  static const String ah = "AH"; // Длинное нажатие
  static const String ar = "A+"; // Поворот направо
  static const String al = "A-"; // Поворот налево
  static const String arh = "AR"; // Поворот направо с нажатой кнопкой
  static const String alh = "AL"; // Поворот налево с нажатой кнопкой
  static const String an = "AN"; // AN** Количество кликов нажатое подряд
  static const String ad = "AD"; // AD** Долгое нажатие на **(ом) клике
  static const String au = "AU"; // Кнопка поднята после удержания

  // Энкодер B (Board)
  static const String bc = "BC"; // Обычное нажатие
  static const String bh = "BH"; // Длинное нажатие
  static const String br = "B+"; // Поворот направо
  static const String bl = "B-"; // Поворот налево
  static const String brh = "BR"; // Поворот направо с нажатой кнопкой
  static const String blh = "BL"; // Поворот налево с нажатой кнопкой
  static const String bn = "BN"; // AN** Количество кликов нажатое подряд
  static const String bd = "BD"; // AD** Долгое нажатие на **(ом) клике
  static const String bu = "BU"; // Кнопка поднята после удержания

  // Энкодер C (Board)
  static const String cc = "CC"; // Обычное нажатие
  static const String ch = "CH"; // Длинное нажатие
  static const String cr = "C+"; // Поворот направо
  static const String cl = "C-"; // Поворот налево
  static const String crh = "CR"; // Поворот направо с нажатой кнопкой
  static const String clh = "CL"; // Поворот налево с нажатой кнопкой
  static const String cn = "CN"; // AN** Количество кликов нажатое подряд
  static const String cd = "CD"; // AD** Долгое нажатие на **(ом) клике
  static const String cu = "CU"; // Кнопка поднята после удержания

  // Калибровка датчиков
  static const String s1 = "S1"; // Откалибровать верхнюю границу датчика молока как **** x10  (1234 = 123.4)
  static const String s2 = "S2"; // Откалибровать нижнюю границу датчика молока как **** x10  (1234 = 123.4)
  static const String s3 = "S3"; // Откалибровать верхнюю границу датчика воды как **** x10  (1234 = 123.4)
  static const String s4 = "S4"; // Откалибровать нижнюю границу датчика воды как **** x10  (1234 = 123.4)
  static const String sr = "SR"; // Сбросить калибровку датчиков на стандартную
}
