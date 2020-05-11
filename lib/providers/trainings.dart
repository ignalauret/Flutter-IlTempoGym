import 'dart:convert';

import 'package:flutter/cupertino.dart';
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
        print(name);
        _trainings.add(
          Training(
            name: name,
            description: data["descripcion"],
            teacher: data["profesor"],
            imageUrl: data["imageUrl"],
            bannerUrl: data["bannerUrl"],
            schedule: (data["horario"] as List).map((schedule) {
              List<String> date = schedule.toString().split(".");
              return DateTime(
                2020,
                int.parse(date[0]),
                int.parse(date[1]),
                int.parse(date[2]),
                int.parse(date[3]),
              );
            }).toList(),
            dbUrl: data["dbUrl"] + "?auth=$authToken",
            maxSchedules: data["maxSchedules"],
            duration: data["duration"],
          ),
        );
      },
    );
    return [_trainings[0], _trainings[2], _trainings[1]];
  }
}
