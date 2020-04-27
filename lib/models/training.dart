import 'package:flutter/material.dart';

class Training {
  final String name;
  final String description;
  final String teacher;
  final String imageUrl;
  final List<DateTime> schedule;
  final String dbUrl;
  final int maxSchedules;

  Training({
    @required this.name,
    @required this.description,
    @required this.teacher,
    @required this.imageUrl,
    @required this.schedule,
    @required this.dbUrl,
    @required this.maxSchedules,
  });
}
