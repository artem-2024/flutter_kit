///
/// 日期转换工具类
///

///日期格式化
enum DateFormat {
  DEFAULT, //yyyy-MM-dd HH:mm:ss.SSS
  NORMAL, //yyyy-MM-dd HH:mm:ss
  YEAR_MONTH_DAY_HOUR_MINUTE, //yyyy-MM-dd HH:mm
  YEAR_MONTH_DAY, //yyyy-MM-dd
  YEAR_MONTH, //yyyy-MM
  MONTH_DAY, //MM-dd
  MONTH_DAY_HOUR_MINUTE, //MM-dd HH:mm
  HOUR_MINUTE_SECOND, //HH:mm:ss
  HOUR_MINUTE, //HH:mm

  ZH_DEFAULT, //yyyy年MM月dd日 HH时mm分ss秒SSS毫秒
  ZH_NORMAL, //yyyy年MM月dd日 HH时mm分ss秒  /  timeSeparate: ":" --> yyyy年MM月dd日 HH:mm:ss
  ZH_YEAR_MONTH_DAY_HOUR_MINUTE, //yyyy年MM月dd日 HH时mm分  /  timeSeparate: ":" --> yyyy年MM月dd日 HH:mm
  ZH_YEAR_MONTH_DAY, //yyyy年MM月dd日
  ZH_YEAR_MONTH_DAY_DOT, //yyyy.MM.dd
  ZH_YEAR_MONTH, //yyyy年MM月
  ZH_MONTH_DAY, //MM月dd日
  ZH_MONTH_DAY_HOUR_MINUTE, //MM月dd日 HH时mm分  /  timeSeparate: ":" --> MM月dd日 HH:mm
  ZH_HOUR_MINUTE_SECOND, //HH时mm分ss秒
  ZH_HOUR_MINUTE, //HH时mm分
}

/// 月份天数
Map<int, int> MONTH_DAY = {
  1: 31,
  2: 28,
  3: 31,
  4: 30,
  5: 31,
  6: 30,
  7: 31,
  8: 31,
  9: 30,
  10: 31,
  11: 30,
  12: 31,
};

class DateConvertUtil {
  /// 字符串转DateTime
  static DateTime? getDateTime(String? dateStr) {
    DateTime? dateTime = DateTime.tryParse(dateStr??'');
    return dateTime;
  }

  /// 时间戳（毫秒）转DateTime
  static DateTime getDateTimeByMilliseconds(int milliseconds,
      {bool isUtc = false}) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: isUtc);
    return dateTime;
  }

  /// 字符串转时间戳
  static int? getDateMillisecondsByTimeStr(String dateStr) {
    DateTime? dateTime = DateTime.tryParse(dateStr);
    return dateTime?.millisecondsSinceEpoch;
  }

  /// 获取当前时间的时间戳（毫秒）
  static int getNowDateMilliseconds() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// 获取当前时间的时间戳（微秒）
  static int getNowDateMicroseconds() {
    return DateTime.now().microsecondsSinceEpoch;
  }

  /// 获取当前日期(yyyy-MM-dd HH:mm:ss)
  static String? getNowDateStr() {
    return getDateStrByDateTime(DateTime.now());
  }

  /// 时间字符串转时间字符串
  /// dateStr         时间字符串
  /// format          时间格式
  /// dateSeparate    天数分割符
  /// timeSeparate    时分秒分割符
  static String? getDateStrByTimeStr(
    String dateStr, {
    DateFormat format = DateFormat.NORMAL,
    String? dateSeparate,
    String? timeSeparate,
  }) {
    return getDateStrByDateTime(getDateTime(dateStr),
        format: format, dateSeparate: dateSeparate, timeSeparate: timeSeparate);
  }

  /// 时间戳转字符串
  /// milliseconds    毫秒
  /// format          时间格式
  /// dateSeparate    天数分割符
  /// timeSeparate    时分秒分割符
  static String? getDateStrByMillisecond(int milliseconds,
      {DateFormat format = DateFormat.NORMAL,
      String? dateSeparate,
      String? timeSeparate,
      bool isUtc = false}) {
    if (milliseconds.toString().length == 10) {
      milliseconds *= 1000;
    }
    DateTime dateTime = getDateTimeByMilliseconds(milliseconds, isUtc: isUtc);
    return getDateStrByDateTime(dateTime,
        format: format, dateSeparate: dateSeparate, timeSeparate: timeSeparate);
  }

  /// DateTime转时间字符串
  /// dateTime        dateTime.
  /// format          时间格式
  /// dateSeparate    天数分割符
  /// timeSeparate    时分秒分割符
  static String? getDateStrByDateTime(DateTime? dateTime,
      {DateFormat format = DateFormat.NORMAL,
      String? dateSeparate,
      String? timeSeparate}) {
    if (dateTime == null) return null;
    String dateStr = dateTime.toString();
    if (isZHFormat(format)) {
      dateStr = formatZHDateTime(dateStr, format, timeSeparate);
    } else {
      dateStr = formatDateTime(dateStr, format, dateSeparate, timeSeparate);
    }
    return dateStr;
  }

  /// 格式化时间
  /// time            时间字符串
  /// format          时间格式
  /// timeSeparate    时分秒分割符
  static String formatZHDateTime(
      String time, DateFormat format, String? timeSeparate) {
    time = convertToZHDateTimeString(time, timeSeparate);
    switch (format) {
      case DateFormat.ZH_NORMAL: //yyyy年MM月dd日 HH时mm分ss秒
        time = time.substring(
            0,
            "yyyy年MM月dd日 HH时mm分ss秒".length -
                (timeSeparate == null || timeSeparate.isEmpty ? 0 : 1));
        break;
      case DateFormat.ZH_YEAR_MONTH_DAY_HOUR_MINUTE: //yyyy年MM月dd日 HH时mm分
        time = time.substring(
            0,
            "yyyy年MM月dd日 HH时mm分".length -
                (timeSeparate == null || timeSeparate.isEmpty ? 0 : 1));
        break;
      case DateFormat.ZH_YEAR_MONTH_DAY: //yyyy年MM月dd日
        time = time.substring(0, "yyyy年MM月dd日".length);
        break;
      case DateFormat.ZH_YEAR_MONTH_DAY_DOT: //yyyy.MM.dd
        time = time.substring(0, "yyyy.MM.dd".length);
        break;
      case DateFormat.ZH_YEAR_MONTH: //yyyy年MM月
        time = time.substring(0, "yyyy年MM月".length);
        break;
      case DateFormat.ZH_MONTH_DAY: //MM月dd日
        time = time.substring("yyyy年".length, "yyyy年MM月dd日".length);
        break;
      case DateFormat.ZH_MONTH_DAY_HOUR_MINUTE: //MM月dd日 HH时mm分
        time = time.substring(
            "yyyy年".length,
            "yyyy年MM月dd日 HH时mm分".length -
                (timeSeparate == null || timeSeparate.isEmpty ? 0 : 1));
        break;
      case DateFormat.ZH_HOUR_MINUTE_SECOND: //HH时mm分ss秒
        time = time.substring(
            "yyyy年MM月dd日 ".length,
            "yyyy年MM月dd日 HH时mm分ss秒".length -
                (timeSeparate == null || timeSeparate.isEmpty ? 0 : 1));
        break;
      case DateFormat.ZH_HOUR_MINUTE: //HH时mm分
        time = time.substring(
            "yyyy年MM月dd日 ".length,
            "yyyy年MM月dd日 HH时mm分".length -
                (timeSeparate == null || timeSeparate.isEmpty ? 0 : 1));
        break;
      default:
        break;
    }
    return time;
  }

  /// 格式化时间
  /// time            时间字符串
  /// format          时间格式
  /// dateSeparate    天数分割符
  /// timeSeparate    时分秒分割符
  static String formatDateTime(String time, DateFormat format,
      String? dateSeparate, String? timeSeparate) {
    switch (format) {
      case DateFormat.NORMAL: //yyyy-MM-dd HH:mm:ss
        time = time.substring(0, "yyyy-MM-dd HH:mm:ss".length);
        break;
      case DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE: //yyyy-MM-dd HH:mm
        time = time.substring(0, "yyyy-MM-dd HH:mm".length);
        break;
      case DateFormat.YEAR_MONTH_DAY: //yyyy-MM-dd
        time = time.substring(0, "yyyy-MM-dd".length);
        break;
      case DateFormat.YEAR_MONTH: //yyyy-MM
        time = time.substring(0, "yyyy-MM".length);
        break;
      case DateFormat.MONTH_DAY: //MM-dd
        time = time.substring("yyyy-".length, "yyyy-MM-dd".length);
        break;
      case DateFormat.MONTH_DAY_HOUR_MINUTE: //MM-dd HH:mm
        time = time.substring("yyyy-".length, "yyyy-MM-dd HH:mm".length);
        break;
      case DateFormat.HOUR_MINUTE_SECOND: //HH:mm:ss
        time =
            time.substring("yyyy-MM-dd ".length, "yyyy-MM-dd HH:mm:ss".length);
        break;
      case DateFormat.HOUR_MINUTE: //HH:mm
        time = time.substring("yyyy-MM-dd ".length, "yyyy-MM-dd HH:mm".length);
        break;
      case DateFormat.ZH_YEAR_MONTH_DAY_DOT: //yyyy.MM.dd
        time = time.substring(0, "yyyy.MM.dd".length);
        break;
      default:
        break;
    }
    time = dateTimeSeparate(time, dateSeparate, timeSeparate);
    return time;
  }

  /// 是否为ZH DateTime字符串
  static bool isZHFormat(DateFormat format) {
    return format == DateFormat.ZH_DEFAULT ||
        format == DateFormat.ZH_NORMAL ||
        format == DateFormat.ZH_YEAR_MONTH_DAY_HOUR_MINUTE ||
        format == DateFormat.ZH_YEAR_MONTH_DAY ||
        format == DateFormat.ZH_YEAR_MONTH ||
        format == DateFormat.ZH_MONTH_DAY ||
        format == DateFormat.ZH_MONTH_DAY_HOUR_MINUTE ||
        format == DateFormat.ZH_HOUR_MINUTE_SECOND ||
        format == DateFormat.ZH_HOUR_MINUTE;
  }

  /// ZH DateTime 转换为字符串
  static String convertToZHDateTimeString(String time, String? timeSeparate) {
    time = time.replaceFirst("-", "年");
    time = time.replaceFirst("-", "月");
    time = time.replaceFirst(" ", "日 ");
    if (timeSeparate == null || timeSeparate.isEmpty) {
      time = time.replaceFirst(":", "时");
      time = time.replaceFirst(":", "分");
      time = time.replaceFirst(".", "秒");
      time = "$time毫秒";
    } else {
      time = time.replaceAll(":", timeSeparate);
    }
    return time;
  }

  /// 时间间隔符
  static String dateTimeSeparate(
      String time, String? dateSeparate, String? timeSeparate) {
    if (dateSeparate != null) {
      time = time.replaceAll("-", dateSeparate);
    }
    if (timeSeparate != null) {
      time = time.replaceAll(":", timeSeparate);
    }
    return time;
  }

  /// 以毫秒为单位获取WeekDay。
  static String? getWeekDayByMilliseconds(int milliseconds,
      {bool isUtc = false}) {
    DateTime dateTime = getDateTimeByMilliseconds(milliseconds, isUtc: isUtc);
    return getWeekDay(dateTime);
  }

  /// 以毫秒为单位获取 ZH WeekDay
  static String? getZHWeekDayByMilliseconds(int milliseconds,
      {bool isUtc = false}) {
    DateTime dateTime = getDateTimeByMilliseconds(milliseconds, isUtc: isUtc);
    return getZHWeekDay(dateTime);
  }

  /// get WeekDay.
  static String? getWeekDay(DateTime? dateTime) {
    if (dateTime == null) return null;
    String? weekday;
    switch (dateTime.weekday) {
      case 1:
        weekday = "Monday";
        break;
      case 2:
        weekday = "Tuesday";
        break;
      case 3:
        weekday = "Wednesday";
        break;
      case 4:
        weekday = "Thursday";
        break;
      case 5:
        weekday = "Friday";
        break;
      case 6:
        weekday = "Saturday";
        break;
      case 7:
        weekday = "Sunday";
        break;
      default:
        break;
    }
    return weekday;
  }

  /// get ZH WeekDay.
  static String? getZHWeekDay(DateTime? dateTime) {
    if (dateTime == null) return null;
    String? weekday;
    switch (dateTime.weekday) {
      case 1:
        weekday = "星期一";
        break;
      case 2:
        weekday = "星期二";
        break;
      case 3:
        weekday = "星期三";
        break;
      case 4:
        weekday = "星期四";
        break;
      case 5:
        weekday = "星期五";
        break;
      case 6:
        weekday = "星期六";
        break;
      case 7:
        weekday = "星期日";
        break;
      default:
        break;
    }
    return weekday;
  }

  /// DateTime 是否为闰年
  static bool isLeapYearByDateTime(DateTime dateTime) {
    return isLeapYearByYear(dateTime.year);
  }

  /// 年份是否为闰年
  static bool isLeapYearByYear(int year) {
    return year % 4 == 0 && year % 100 != 0 || year % 400 == 0;
  }

  /// 是否是昨天.
  static bool isYesterdayByMilliseconds(int millis, int locMillis) {
    return isYesterday(DateTime.fromMillisecondsSinceEpoch(millis),
        DateTime.fromMillisecondsSinceEpoch(locMillis));
  }

  /// 是否是昨天.
  static bool isYesterday(DateTime dateTime, DateTime locDateTime) {
    if (yearIsEqual(dateTime, locDateTime)) {
      int spDay = DateConvertUtil.getDayOfYear(locDateTime) -
          DateConvertUtil.getDayOfYear(dateTime);
      return spDay == 1;
    } else {
      return ((locDateTime.year - dateTime.year == 1) &&
          dateTime.month == 12 &&
          locDateTime.month == 1 &&
          dateTime.day == 31 &&
          locDateTime.day == 1);
    }
  }

  /// 在今年的第几天.
  static int getDayOfYearByMilliseconds(int millis) {
    return getDayOfYear(DateTime.fromMillisecondsSinceEpoch(millis));
  }

  /// 在今年的第几天.
  static int getDayOfYear(DateTime dateTime) {
    int year = dateTime.year;
    int month = dateTime.month;
    int days = dateTime.day;
    for (int i = 1; i < month; i++) {
      days = days + MONTH_DAY[i]!;
    }
    if (isLeapYearByYear(year) && month > 2) {
      days = days + 1;
    }
    return days;
  }

  /// 是否同年.
  static bool yearIsEqualByMilliseconds(int millis, int locMillis) {
    return yearIsEqual(DateTime.fromMillisecondsSinceEpoch(millis),
        DateTime.fromMillisecondsSinceEpoch(locMillis));
  }

  /// 是否同年.
  static bool yearIsEqual(DateTime dateTime, DateTime locDateTime) {
    return dateTime.year == locDateTime.year;
  }

  /// 是否是今天.
  static bool isToday(int? milliseconds, {bool isUtc = false}) {
    if (milliseconds == null || milliseconds == 0) return false;
    DateTime old =
        DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: isUtc);
    DateTime now = isUtc ? DateTime.now().toUtc() : DateTime.now().toLocal();
    return old.year == now.year && old.month == now.month && old.day == now.day;
  }

  ///是否同一天
  static bool isSameDay(DateTime dayOne, DateTime dayTwo) {
    return dayOne.year == dayTwo.year &&
        dayOne.month == dayTwo.month &&
        dayOne.day == dayTwo.day;
  }

  static DateTime firstDayOfMonth(DateTime month) {
    return DateTime.utc(month.year, month.month, 1, 12);
  }

  static DateTime lastDayOfMonth(DateTime month) {
    final date = month.month < 12
        ? DateTime.utc(month.year, month.month + 1, 1, 12)
        : DateTime.utc(month.year + 1, 1, 1, 12);
    return date.subtract(const Duration(days: 1));
  }

  /// 根据时间戳转化为时长（时分秒 hh:mm:ss格式）
  static String getHMSOfMilliseconds(int milliseconds,{bool showZero=false}) {
    int integerMilliseconds = milliseconds ~/ 1000;
    int hour = (integerMilliseconds ~/ 3600) % 24;
    int minute = integerMilliseconds % 3600 ~/ 60;
    int second = integerMilliseconds % 60;

    /// padLeft表示字符不够2位的时候在左边添加占位符0
    if (hour != 0||showZero==true) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
    } else {
      return '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
    }
  }

  /// 根据时间戳转化为时长（时分秒 hh:mm格式）只有分钟显示分钟，剩下一分钟显示返回xx秒
  static String getHMOfMilliseconds(int milliseconds,{bool showZero=false}) {
    int integerMilliseconds = milliseconds ~/ 1000;
    int hour = (integerMilliseconds ~/ 3600) % 24;
    int minute = integerMilliseconds % 3600 ~/ 60;
    int second = integerMilliseconds % 60;

    /// padLeft表示字符不够2位的时候在左边添加占位符0
    if (hour != 0||showZero==true) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } else if (minute != 0) {
      return '${minute.toString().padLeft(2, '0')}分钟';
    } else {
      return '${second.toString().padLeft(2, '0')}秒';
    }
  }
  /// 根据时间戳转化为时长（时分秒 hh:mm格式）
  static String getHMSOfMilliseconds2(int milliseconds) {
    int integerMilliseconds = milliseconds ~/ 1000;
    int hour = (integerMilliseconds ~/ 3600) % 24;
    int minute = integerMilliseconds % 3600 ~/ 60;

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(
        2, '0')}';
  }
}
