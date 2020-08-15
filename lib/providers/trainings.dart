import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:iltempo/utils/utils.dart';
import '../models/training.dart';

import 'package:http/http.dart' as http;

class Trainings with ChangeNotifier {
  Trainings(this.authToken);

  List<Training> _trainings = [];
  final String authToken;

  Future<List<Training>> fetchTrainings() async {
    if (_trainings.isNotEmpty) return [..._trainings];
    final response = await http.get(
        "https://il-tempo-dda8e.firebaseio.com/trainings.json?auth=$authToken");
    final trainings = json.decode(response.body) as Map<String, dynamic>;
    trainings.forEach(
      (name, data) {
        _trainings.add(
          Training(
            name: name,
            description: data["descripcion"],
            teacher: data["profesor"],
            imageUrl: data["imageUrl"],
            bannerUrl: data["bannerUrl"],
            interval: data["intervalo"] == null
                ? 0
                : int.parse(data["intervalo"].toString()),
            schedule: (data["horario"] as List).map((schedule) {
              List<String> date = schedule.toString().split(".");
              final List<DateTime> result = [];
              if (schedule.toString().contains("a")) {
                List<String> dates = schedule.toString().split("a");
                dates.forEach((date) {
                  final splitDate = date.split(".");
                  result.add(
                    DateTime(
                      2020,
                      int.parse(splitDate[0]),
                      int.parse(splitDate[1]),
                      int.parse(splitDate[2]),
                      int.parse(splitDate[3]),
                    ),
                  );
                });
              } else
                result.add(
                  DateTime(
                    2020,
                    int.parse(date[0]),
                    int.parse(date[1]),
                    int.parse(date[2]),
                    int.parse(date[3]),
                  ),
                );
              return result;
            }).toList(),
            maxSchedules: data["maxSchedules"],
            freeGymMaxSchedules: name == "Musculacion"
                ? data["freeGymMaxSchedules"]
                : data["maxSchedules"],
            duration: data["duration"],
          ),
        );
      },
    );
    return [..._trainings];
  }

  // If there is a group class at the same schedule return normal schedule,
  // else return bigger schedule.
  int getMaxSchedule(Training training, DateTime schedule) {
    if (_isGroupClassAtSchedule(schedule)) {
      return training.maxSchedules;
    } else {
      return training.freeGymMaxSchedules;
    }
  }

  // Check if there is a group class at the selected schedule
  bool _isGroupClassAtSchedule(DateTime schedule) {
    for (Training training in _trainings) {
      if (training.name == "Musculacion") continue;
      for (DateTime trainingSchedule in training.getParsedSchedule()) {
        if (isSameSchedule(trainingSchedule, schedule)) return true;
      }
    }
    return false;
  }
}
