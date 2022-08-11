import 'package:get/get.dart';
import 'package:intl/intl.dart';

DateUtils dateUtils = DateUtils();

class DateUtils {
  static final DateUtils _dateUtils = DateUtils._i();

  factory DateUtils() {
    return _dateUtils;
  }

  DateUtils._i();

  String fomat_1 = "yyyy-MM-dd HH:mm:ss";
  String fomat_2 = "dd/MM/yyyy hh:mm:ss a";
  String fomat_3 = "EEE, dd MMM, HH:mm";
  String fomat_4 = "hh:mm:ss a";
  String fomat_5 = "yyyy-MM-ddThh:mm:ss";
  String fomat_6 = "MMM yyyy";

  String formattedDate(
    DateTime dateTime,
    String format, {
    bool isLocal = true,
    bool thaiYear = false,
  }) {
    if (isLocal) {
      dateTime = dateTime.toLocal();
    }
    if (thaiYear) {
      dateTime = DateTime(
        dateTime.year + 543,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
        dateTime.microsecond,
        dateTime.millisecond,
      );
    }
    return DateFormat(format, Get.locale!.languageCode).format(dateTime);
    // return DateFormat.d('en').add_MMM().add_y().format(dateTime);
  }

  String? formattedDateStr(
    String? dateStr,
    String format, {
    bool isLocal = true,
    bool thaiYear = false,
  }) {
    if (dateStr == null) return null;
    var dateTime = DateTime.parse(dateStr);
    if (isLocal) {
      dateTime = dateTime.toLocal();
    }
    if (thaiYear) {
      dateTime = DateTime(
        dateTime.year + 543,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
        dateTime.microsecond,
        dateTime.millisecond,
      );
    }
    return DateFormat(format, Get.locale!.languageCode).format(dateTime);
    // return DateFormat.d('en').add_MMM().add_y().format(dateTime);
  }

  String convertDateFormat(
    String date,
    String newFormat, {
    bool toLocal = true,
    bool thaiYear = false,
  }) {
    DateTime dateTime = DateTime.parse(date);
    if (toLocal) {
      dateTime = dateTime.toLocal();
    }
    if (thaiYear) {
      dateTime = DateTime(
        dateTime.year + 543,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
        dateTime.microsecond,
        dateTime.millisecond,
      );
    }
    return DateFormat(newFormat, Get.locale!.languageCode).format(dateTime);
  }

  String convertDateFormatFromOld(
      String date, String oldFormat, String newFormat) {
    //
    DateTime oldDate = DateFormat(oldFormat).parse(date);
    return DateFormat(newFormat).format(oldDate);
  }

  DateTime convertStrFromOldToDate(String date, String oldFormat) {
    return DateFormat(oldFormat).parse(date);
  }

  String convertDateFromTimestamp(int timestamp, String newFormat,
      {bool toLocal = true}) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat(newFormat).format(dateTime);
  }

  DateTime convertStrToDate2(String date, String newFormat) {
    return DateFormat(newFormat).parse(date);
  }

  String convertDateFormatTo(String value,
      [String formatFm = 'dd/MM/yyyy', String formatTo = 'yyyy-MM-dd']) {
    DateFormat formatter = DateFormat(formatFm);
    DateFormat outputFormat = DateFormat(formatTo);

    var date1 = formatter.parse(value);
    return outputFormat.format(date1); // 2019-08-18
  }

  DateTime convertStrToDate(String date,
      {String? format, bool toLocal = true}) {
    DateTime dateTime = DateTime.parse(date);
    if (toLocal) {
      dateTime = dateTime.toLocal();
    }
    //return DateFormat(format).parse(date);
    return dateTime;
  }

  DateTime getDateFromTimeStamp(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /*bool isToday(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    return diff == 0 && now.day == date.day;
  }*/

  bool isToday(DateTime date) {
    var now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  bool isDateTimeBetweenToDate(
      {required DateTime toDate,
      required DateTime startDateTime,
      required DateTime endDateTime}) {
    return startDateTime.isBefore(toDate) && endDateTime.isAfter(toDate);
  }

  int checkDateFromTimestamp(DateTime date) {
    // DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime now = DateTime.now();

    //  0 == today
    // >0 == tomorrow  (1,2,3,....)
    // <0 == yesterday (-1,-2,-3,....)

    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  String getDifference(DateTime startDate, DateTime endDate) {
    return formatDuration(startDate.difference(endDate).abs());
    //return startDate.difference(endDate).inHours.abs();
  }

  int getDifferenceInSeconds(DateTime startDate, DateTime endDate) {
    return startDate.difference(endDate).inSeconds.abs();
  }

  int getDifferenceInDay(DateTime startDate, DateTime endDate) {
    return startDate.difference(endDate).inDays.abs();
  }

  int getDifferenceInMillis(DateTime startDate, DateTime endDate) {
    return startDate.difference(endDate).inMilliseconds.abs();
  }

  int getDifferenceInMinutes(DateTime startDate, DateTime endDate) {
    return startDate.difference(endDate).inMinutes.abs();
  }

  int getDifferenceInHours(DateTime startDate, DateTime endDate) {
    return startDate.difference(endDate).inHours.abs();
  }

  String getDurationByDates(String s, String e) {
    String value = "";

    DateTime startTime = DateFormat("hh:mm a").parse(s);
    DateTime endTime = DateFormat("hh:mm a").parse(e);

    int hours = getDifferenceInHours(startTime, endTime);
    if (hours >= 1) {
      value = "${hours}hr";
    } else {
      int minutes = getDifferenceInMinutes(startTime, endTime);
      value = "${minutes}min";
    }

    return value;
  }

  String formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, '0');
  }

  String formatDurationInType(Duration duration, {int type = 0}) {
    //0 = HH:mm:ss
    //1 = mm:ss
    //2 = mm:ss:nn
    //3 = ss

    if (duration == null) {
      return "-";
    }

    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMilliSeconds =
        twoDigits(duration.inMilliseconds.remainder(60));

    if (type == 3) {
      return twoDigitSeconds;
    } else if (type == 2) {
      return "$twoDigitMinutes:$twoDigitSeconds:$twoDigitMilliSeconds";
    } else if (type == 1) {
      return "$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  ///
  DateTime toMidnight(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  bool isPastDay(DateTime date) {
    var today = toMidnight(DateTime.now());
    return date.isBefore(today);
  }

  DateTime addDaysToDate(DateTime date, int days) {
    DateTime newDate = date.add(Duration(days: days));

    if (date.hour != newDate.hour) {
      var hoursDifference = date.hour - newDate.hour;

      if (hoursDifference <= 3 && hoursDifference >= -3) {
        newDate = newDate.add(Duration(hours: hoursDifference));
      } else if (hoursDifference <= -21) {
        newDate = newDate.add(Duration(hours: 24 + hoursDifference));
      } else if (hoursDifference >= 21) {
        newDate = newDate.add(Duration(hours: hoursDifference - 24));
      }
    }
    return newDate;
  }

  bool isSpecialPastDay(DateTime date) {
    return isPastDay(date) || (isToday(date) && DateTime.now().hour >= 12);
  }

  DateTime getFirstDayOfCurrentMonth() {
    var dateTime = DateTime.now();
    dateTime = getFirstDayOfMonth(dateTime);
    return dateTime;
  }

  DateTime getFirstDayOfNextMonth() {
    var dateTime = getFirstDayOfCurrentMonth();
    dateTime = addDaysToDate(dateTime, 31);
    dateTime = getFirstDayOfMonth(dateTime);
    return dateTime;
  }

  DateTime getLastDayOfCurrentMonth() {
    return getLastDayOfMonth(DateTime.now());
  }

  DateTime getLastDayOfNextMonth() {
    return getLastDayOfMonth(getFirstDayOfNextMonth());
  }

  DateTime addMonths(DateTime fromMonth, int months) {
    DateTime firstDayOfCurrentMonth = fromMonth;
    for (int i = 0; i < months; i++) {
      firstDayOfCurrentMonth = getLastDayOfMonth(firstDayOfCurrentMonth)
          .add(const Duration(days: 1));
    }

    return firstDayOfCurrentMonth;
  }

  DateTime getFirstDayOfMonth(DateTime month) {
    return DateTime(month.year, month.month);
  }

  DateTime getLastDayOfMonth(DateTime month) {
    DateTime firstDayOfMonth = DateTime(month.year, month.month);
    DateTime nextMonth = firstDayOfMonth.add(const Duration(days: 32));
    DateTime firstDayOfNextMonth = DateTime(nextMonth.year, nextMonth.month);
    return firstDayOfNextMonth.subtract(const Duration(days: 1));
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }

  bool isCurrentMonth(DateTime date) {
    var now = DateTime.now();
    return date.month == now.month && date.year == now.year;
  }

  int calculateMaxWeeksNumberMonthly(DateTime startDate, DateTime endDate) {
    int monthsNumber = calculateMonthsDifference(startDate, endDate);

    List<int> weeksNumbersMonthly = [];

    if (monthsNumber == 0) {
      return calculateWeeksNumber(startDate, endDate);
    } else {
      weeksNumbersMonthly
          .add(calculateWeeksNumber(startDate, getLastDayOfMonth(startDate)));

      DateTime firstDateOfMonth = getFirstDayOfMonth(startDate);
      for (int i = 1; i <= monthsNumber - 2; i++) {
        firstDateOfMonth = firstDateOfMonth.add(const Duration(days: 31));
        weeksNumbersMonthly.add(calculateWeeksNumber(
            firstDateOfMonth, getLastDayOfMonth(firstDateOfMonth)));
      }

      weeksNumbersMonthly
          .add(calculateWeeksNumber(getFirstDayOfMonth(endDate), endDate));

      weeksNumbersMonthly.sort((a, b) => b.compareTo(a));
      return weeksNumbersMonthly[0];
    }
  }

  int calculateMonthsDifference(DateTime startDate, DateTime endDate) {
    var yearsDifference = endDate.year - startDate.year;
    return 12 * yearsDifference + endDate.month - startDate.month;
  }

  int calculateWeeksNumber(DateTime monthStartDate, DateTime monthEndDate) {
    int rowsNumber = 1;

    DateTime currentDay = monthStartDate;
    while (currentDay.isBefore(monthEndDate)) {
      currentDay = currentDay.add(const Duration(days: 1));
      if (currentDay.weekday == DateTime.monday) {
        rowsNumber += 1;
      }
    }

    return rowsNumber;
  }

  String getDayOfMonthSuffix(int dayNum) {
    if (!(dayNum >= 1 && dayNum <= 31)) {
      throw Exception('Invalid day of month');
    }

    if (dayNum >= 11 && dayNum <= 13) {
      return 'th';
    }

    switch (dayNum % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String getDayOfMonthFromDate(DateTime dateTime) {
    int day = int.parse(formattedDate(dateTime, "d"));
    return "$day${getDayOfMonthSuffix(day)}";
  }

  static DateTime? parseStringToDate(String date,
      {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    if (date.isEmpty) return null;
    return DateFormat(format).parseUTC(date);
  }

  static String? parseDateToString(DateTime date,
      {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    if (date == null) return null;
    return DateFormat(format).format(date);
  }

  static DateTime utcToLocal(DateTime date,
      {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    DateTime parsedUTCDate =
        DateFormat(format).parseUTC(parseDateToString(date)!);
    return parsedUTCDate.toLocal();
  }

  static DateTime localToUtc(DateTime date,
      {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    DateTime parsedLocalDate =
        DateFormat(format).parse(parseDateToString(date)!);
    return parsedLocalDate.toUtc();
  }

  String timeAgoSinceDate(String dateString, {bool numericDates = true}) {
    DateTime date = DateTime.parse(dateString);
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if ((difference.inDays / 365).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if ((difference.inDays / 365).floor() >= 1) {
      return (numericDates) ? '1 year ago' : 'Last year';
    } else if ((difference.inDays / 30).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} months ago';
    } else if ((difference.inDays / 30).floor() >= 1) {
      return (numericDates) ? '1 month ago' : 'Last month';
    } else if ((difference.inDays / 7).floor() >= 2) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 hour ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 minute ago' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }
}
