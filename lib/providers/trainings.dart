import 'package:flutter/cupertino.dart';
import '../models/training.dart';

class Trainings with ChangeNotifier {
  Trainings(this.authToken);

  //List<Training> _trainings = [];
  final String authToken;

  List<Training> get trainings {
    return [
      Training(
        name: "Musculación",
        description: "Hacemos musculacion",
        teacher: "Prof. Jorge Gonzalez",
        imageUrl: "assets/img/musculacion.jpg",
        schedule: [
          DateTime(2020, 4, 27, 9, 30),
          DateTime(2020, 4, 27, 18, 30),
          DateTime(2020, 4, 29, 17, 0)
        ],
        dbUrl:
            "https://il-tempo-dda8e.firebaseio.com/musculacion.json?auth=$authToken",
        maxSchedules: 3,
      ),
      Training(
        name: "Zumba",
        description: "Hacemos musculacion",
        teacher: "Prof. Adrian Gimenez",
        imageUrl: "assets/img/zumba.jpg",
        schedule: [
          DateTime(2020, 4, 27, 9, 30),
          DateTime(2020, 4, 27, 18, 30),
          DateTime(2020, 4, 29, 17, 0)
        ],
        dbUrl:
            "https://il-tempo-dda8e.firebaseio.com/zumba.json?auth=$authToken",
        maxSchedules: 2,
      ),
      Training(
        name: "Spinning",
        description: "Hacemos musculacion",
        teacher: "Prof. Gabriela Rodriguez",
        imageUrl: "assets/img/spinning.jpeg",
        schedule: [
          DateTime(2020, 4, 27, 9, 30),
          DateTime(2020, 4, 27, 18, 30),
          DateTime(2020, 4, 29, 17, 0)
        ],
        dbUrl:
            "https://il-tempo-dda8e.firebaseio.com/spinning.json?auth=$authToken",
        maxSchedules: 2,
      ),
    ];
  }
}
