import 'package:flutter/material.dart';

class Training {
  final String name;
  final String description;
  final String teacher;
  final String imageUrl;
  final String bannerUrl;
  final List<List<DateTime>> schedule;
  final int maxSchedules;
  final String duration;
  final int interval;

  Training({
    @required this.name,
    @required this.description,
    @required this.teacher,
    @required this.imageUrl,
    @required this.schedule,
    @required this.maxSchedules,
    @required this.bannerUrl,
    @required this.duration,
    @required this.interval,
  });

  List<DateTime> getParsedSchedule() {
    final List<DateTime> result = [];
    schedule.forEach(
      (listDates) {
        if (listDates.length == 1) {
          result.add(listDates[0]);
        } else {
          var scheduleHour = DateTime(listDates[0].year, listDates[0].month,
              listDates[0].day, listDates[0].hour, listDates[0].minute);
          while (scheduleHour.isBefore(listDates.last)) {
            print(scheduleHour);
            result.add(scheduleHour);
            scheduleHour = scheduleHour.add(Duration(minutes: this.interval));
          }
        }
      },
    );
    return result;
  }
}
