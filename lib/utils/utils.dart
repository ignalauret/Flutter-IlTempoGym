import 'package:intl/intl.dart';

// Return if d1 is before d2 relative to their hours.
bool compareHours(DateTime d1, DateTime d2) {
  if (d1.hour > d2.hour) return false;
  if (d1.hour == d2.hour && d1.minute > d2.minute) return false;
  if (d1.hour == d2.hour && d1.minute == d2.minute && d1.second > d2.second)
    return false;
  return true;
}

// Return if date d1 is before date d2.
int compareDates(String d1, String d2) {
  List<String> date1 = d1.split("/");
  List<String> date2 = d2.split("/");
  // Check months.
  if (int.parse(date1[1]) < int.parse(date2[1])) return -1;
  if (int.parse(date1[1]) > int.parse(date2[1])) return 1;
  // Check days
  if (int.parse(date1[0]) < int.parse(date2[0])) return -1;
  if (int.parse(date1[0]) > int.parse(date2[0])) return 1;
  return 0;
}

DateTime nextClassDay(List<DateTime> possibleDays) {
  for (int i = 0; i < 7; i++) {
    for (DateTime day in possibleDays) {
      if (day.weekday == DateTime.now().add(Duration(days: i)).weekday) {
        if (i != 0 || compareHours(DateTime.now(), day)) {
          return DateTime.now().add(Duration(days: i));
        }
      }
    }
  }
  return null;
}

int dayToInt(String day) {
  switch (day) {
    case "Lun":
      return 1;
    case "Mar":
      return 2;
    case "Mie":
      return 3;
    case "Jue":
      return 4;
    case "Vie":
      return 5;
    case "Sab":
      return 6;
  }
  return 1;
}

String intToDay(int weekday) {
  switch (weekday) {
    case (1):
      return "Lun";
    case (2):
      return "Mar";
    case (3):
      return "Mie";
    case (4):
      return "Jue";
    case (5):
      return "Vie";
    case (6):
      return "Sab";
  }
  return "Lun";
}

List<String> hoursOfDay(List<List<DateTime>> schedules, String day) {
  List<String> hours = [];
  schedules.forEach((schedule) {
    if (schedule[0].weekday == dayToInt(day)) {
      if (schedule.length == 1) {
        hours.add(DateFormat("H:mm").format(schedule[0]));
      } else {
        hours.add(DateFormat("H:mm").format(schedule[0]) + " a");
        hours.add(DateFormat("H:mm").format(schedule[1]));
      }
    }
  });
  return hours;
}

List<int> getParsedHour(String time) {
  final values = time.split(":");
  return [int.parse(values[0]), int.parse(values[1])];
}

bool isSameSchedule(DateTime schedule1, DateTime schedule2) {
  if (schedule1.weekday != schedule2.weekday) return false;
  if (schedule1.hour != schedule2.hour) return false;
  if (schedule1.minute != schedule2.minute) return false;
  return true;
}

String formatDate(DateTime date) {
  String day = "";
  switch (date.weekday) {
    case 1:
      day = "Lunes";
      break;
    case 2:
      day = "Martes";
      break;
    case 3:
      day = "Miércoles";
      break;
    case 4:
      day = "Jueves";
      break;
    case 5:
      day = "Viernes";
      break;
    case 6:
      day = "Sábado";
      break;
  }
  String number = date.day.toString();
  String month = "";
  switch (date.month) {
    case 1:
      month = "Enero";
      break;
    case 2:
      month = "Febrero";
      break;
    case 3:
      month = "Marzo";
      break;
    case 4:
      month = "Abril";
      break;
    case 5:
      month = "Mayo";
      break;
    case 6:
      month = "Junio";
      break;
    case 7:
      month = "Julio";
      break;
    case 8:
      month = "Agosto";
      break;
    case 9:
      month = "Septiembre";
      break;
    case 10:
      month = "Octubre";
      break;
    case 11:
      month = "Noviembre";
      break;
    case 12:
      month = "Diciembre";
      break;
  }
  return "$day $number de $month";
}

DateTime parseDate(String date) {
  if(date == null) return null;
  final arr = date.split("/");
  return DateTime(int.parse(arr[2]), int.parse(arr[1]), int.parse(arr[0]));
}
