String nextClassDay(List<String> possibleDays) {
  List<int> intDays = [];
  possibleDays.forEach((day) {
    intDays.add(dayToInt(day));
  });
  for (int i = 0; i < 7; i++) {
    if (intDays.contains(DateTime.now().add(Duration(days: i)).weekday))
      return intToDay(DateTime.now().add(Duration(days: i)).weekday);
  }
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
