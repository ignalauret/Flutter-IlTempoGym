import 'package:flutter/material.dart';

class Turn {
  String id;
  String training;
  String date;
  String hour;
  String dni;

  Turn({this.id, this.hour, this.training, this.date, this.dni});

  DateTime get actualDate {
    return DateTime(
      DateTime.now().year,
      int.parse(date.split("/").last),
      int.parse(date.split("/").first),
      int.parse(hour.split(":").first),
      int.parse(hour.split(":").last),
    );
  }

  bool get hasPassed => DateTime.now().isAfter(actualDate);
}
