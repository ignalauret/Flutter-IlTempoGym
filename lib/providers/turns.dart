import 'package:flutter/material.dart';
import 'package:iltempo/models/training.dart';
import 'package:iltempo/providers/trainings.dart';
import 'package:iltempo/utils/constants.dart';
import 'package:iltempo/utils/utils.dart';
import '../models/turn.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class Turns extends ChangeNotifier {
  Turns(this.authToken, this.userDni, this.userExpireDate);

  final String authToken;
  final String userDni;
  final DateTime userExpireDate;
  List<Turn> _turns = [];
  int _expireMarginDays;

  bool _newTurn;

  set newTurn(bool turn) {
    _newTurn = turn;
    notifyListeners();
  }

  Future<int> get expireMarginDays async {
    if (_expireMarginDays == null) {
      await getExpireMargin();
    }
    return _expireMarginDays;
  }

  Future<void> getExpireMargin() async {
    final response = await http
        .get(kFirebaseUrl + '/config/expireMargin.json?auth=$authToken');
    if (response.statusCode == 200) {
      _expireMarginDays = int.parse(response.body);
      notifyListeners();
    }
  }

  Future<List<Turn>> getUsersTurns() async {
    if (_turns.isNotEmpty && !_newTurn) return [..._turns];
    _turns = [];
    _newTurn = false;
    final response = await http.get(kFirebaseUrl +
        '/turnos.json?auth=$authToken&orderBy="dni"&equalTo="$userDni"');
    if (response == null) return [];
    final turns = json.decode(response.body) as Map<String, dynamic>;
    turns.forEach((id, data) {
      Turn turn = Turn(
        id: id,
        hour: data["hora"],
        training: data["clase"],
        date: data["fecha"],
      );
      _turns.add(turn);
    });
    _turns.sort((turn1, turn2) => compareDates(turn1.date, turn2.date) * -1);
    return [..._turns];
  }

  Future<List<Turn>> getTurnsOfDay(String day, String training) async {
    final response = await http.get(kFirebaseUrl +
        '/turnos.json?auth=$authToken&orderBy="fecha"&equalTo="$day"');
    if (response == null) return [];
    final turns = json.decode(response.body) as Map<String, dynamic>;
    final List<Turn> result = [];
    turns.forEach((id, data) {
      if (data["clase"] == training) {
        Turn turn = Turn(
          id: id,
          hour: data["hora"],
          training: data["clase"],
          date: data["fecha"],
          dni: data["dni"],
        );
        result.add(turn);
      }
    });
    return result;
  }

  /*
    Return codes:
      - 200: Success, created turn.
      - 201: Success, but expires soon.
      - 400: Error, user payment expired.
      - 401: Error, turn no longer available.
      - 404: Error, server side.
   */
  Future<int> createTurn({
    BuildContext context,
    Training training,
    String dni,
    String name,
    String date,
    String hour,
  }) async {
    // Check if expired
    if (userExpireDate == null) return 400;
    if (userExpireDate.isBefore(
        DateTime.now().subtract(Duration(days: await expireMarginDays))))
      return 400;
    // Check again if turn is available
    final List<Turn> turnsOfDay = await getTurnsOfDay(date, training.name);
    final int turnsOfHour =
        turnsOfDay.fold(0, (prev, turn) => turn.hour == hour ? prev + 1 : prev);
    final selectedDate = DateTime(
      DateTime.now().year,
      int.parse(date.split("/").last),
      int.parse(date.split("/").first),
      int.parse(hour.split(":").first),
      int.parse(hour.split(":").last),
    );
    if (turnsOfHour >= getMaxCount(context, training, selectedDate)) return 401;
    // Create the turn
    final response = await http.post(
      kFirebaseUrl + "/turnos.json?auth=$authToken",
      body: json.encode({
        "dni": dni,
        "nombre": name,
        "clase": training.name,
        "fecha": date,
        "hora": hour,
      }),
    );
    if (response.statusCode == 200) {
      newTurn = true;
      if (userExpireDate.isBefore(DateTime.now().add(Duration(days: 7))))
        return 201;
      return 200;
    } else {
      return 404;
    }
  }

  int getMaxCount(
      BuildContext context, Training training, DateTime selectedDate) {
    if (training.name != "Musculación") return training.maxSchedules;
    final maxSchedules = Provider.of<Trainings>(context, listen: false)
        .getMaxSchedule(training, selectedDate);
    return maxSchedules;
  }

  Future<bool> cancelTurn(String id, String training) async {
    // Remove from DB
    final response =
        await http.delete(kFirebaseUrl + "/turnos/$id.json?auth=$authToken");
    if (response.statusCode == 200) {
      // Remove from memory
      _turns.removeWhere((turn) => turn.id == id);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }
}
