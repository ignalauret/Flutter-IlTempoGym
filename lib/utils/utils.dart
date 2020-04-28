import 'package:intl/intl.dart';

DateTime nextClassDay(List<DateTime> possibleDays) {
  for (int i = 0; i < 7; i++) {
    DateTime returnDay;
    possibleDays.forEach((day) {
      if(day.weekday == DateTime.now().add(Duration(days:i)).weekday && (i == 0 && compareHours(day, DateTime.now())))
        returnDay = day;
    });
    if(returnDay != null) return returnDay;
  }
  return null;
}

// Return if d1 is before d2 relative to their hours.
bool compareHours(DateTime d1, DateTime d2) {
  if(d1.hour > d2.hour) return false;
  if(d1.minute > d2.minute) return false;
  if(d1.second > d2.second) return false;
  return true;
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

List<String> hoursOfDay(List<DateTime> schedules, String day) {
  List<String> hours = [];
  schedules.forEach((schedule) {
    if (schedule.weekday == dayToInt(day))
      hours.add(DateFormat("H:mm").format(schedule));
  });
  return hours;
}

String formatDate(DateTime date) {
  String day = "";
  switch(date.weekday) {
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
  switch(date.month) {
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
