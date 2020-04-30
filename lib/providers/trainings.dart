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
        description:
            "Capacidad general de rendimiento.Mejora la postura.Mejora de la fuerza muscular",
        teacher: "Jorge Gonzalez",
        imageUrl: "assets/img/musculacion.jpg",
        bannerUrl: "assets/img/musculacion2.jpg",
        schedule: [
          DateTime(2020, 4, 27, 9, 30),
          DateTime(2020, 4, 27, 18, 30),
          DateTime(2020, 4, 29, 17, 0),
        ],
        dbUrl:
            "https://il-tempo-dda8e.firebaseio.com/musculacion.json?auth=$authToken",
        maxSchedules: 3,
      ),
      Training(
        name: "Zumba",
        description:
            "Tonifica y moldea tu cuerpo.Mejora tu coordinación y agilidad. Mejora la salud de tus huesos.Aumenta tu capacidad pulmonar",
        teacher: "Adrian Gimenez",
        imageUrl: "assets/img/zumba.jpg",
        bannerUrl: "assets/img/zumba2.jpg",
        schedule: [
          DateTime(2020, 4, 27, 9, 30),
          DateTime(2020, 4, 27, 17, 00),
          DateTime(2020, 4, 29, 17, 00)
        ],
        dbUrl:
            "https://il-tempo-dda8e.firebaseio.com/zumba.json?auth=$authToken",
        maxSchedules: 3,
      ),
      Training(
        name: "Spinning",
        description:
            "Ayuda a estilizar la figura.Fortalecer huesos y músculos.Mejorar el sistema cardiovascular.Mejorar el sistema cardiovascular",
        teacher: "Lic. Gabriela Rodriguez",
        imageUrl: "assets/img/spinning.jpeg",
        bannerUrl: "assets/img/spinning2.jpg",
        schedule: [
          DateTime(2020, 4, 27, 9, 30),
          DateTime(2020, 4, 27, 18, 30),
          DateTime(2020, 4, 29, 18, 30)
        ],
        dbUrl:
            "https://il-tempo-dda8e.firebaseio.com/spinning.json?auth=$authToken",
        maxSchedules: 3,
      ),
    ];
  }

  String getUrlOf(String training) {
    switch(training) {
      case "Musculacion":
        return trainings[0].dbUrl;
      case "Spinning":
        return trainings[1].dbUrl;
      case "Zumba":
        return trainings[2].dbUrl;
    }
    return null;
  }
}
