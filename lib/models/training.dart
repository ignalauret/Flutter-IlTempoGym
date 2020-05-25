import 'package:flutter/material.dart';

class Training {
  final String name;
  final String description;
  final String teacher;
  final String imageUrl;
  final String bannerUrl;
  final List<List<DateTime>> schedule;
  final String dbUrl;
  final int maxSchedules;
  final String duration;

  Training({
    @required this.name,
    @required this.description,
    @required this.teacher,
    @required this.imageUrl,
    @required this.schedule,
    @required this.dbUrl,
    @required this.maxSchedules,
    @required this.bannerUrl,
    @required this.duration,
  });

  List<DateTime> getParsedSchedule() {
    print(schedule);
    final List<DateTime> result = [];
    schedule.forEach(
      (listDates) {
        if (listDates.length == 1) {
          result.add(listDates[0]);
        } else {
          final int hours = listDates[1].hour - listDates[0].hour;
          for (int i = 0; i <= hours; i++) {
            result.add(
              DateTime(listDates[0].year, listDates[0].month, listDates[0].day,
                  listDates[0].hour + i, listDates[0].minute),
            );
          }
        }
      },
    );
    return result;
  }
}
