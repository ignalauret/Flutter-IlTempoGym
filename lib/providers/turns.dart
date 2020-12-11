import 'package:flutter/material.dart';
import 'package:iltempo/models/training.dart';
import 'package:iltempo/utils/utils.dart';
import '../models/turn.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final response = await http.get(
        'https://il-tempo-dda8e.firebaseio.com/expireMargin.json?auth=$authToken');
    if (response.statusCode == 200) {
      _expireMarginDays = int.parse(response.body);
      notifyListeners();
    }
  }

  Future<List<Turn>> getUsersTurns() async {
    if (_turns.isNotEmpty && !_newTurn) return [..._turns];
    _turns = [];
    _newTurn = false;
    final response = await http.get(
        'https://il-tempo-dda8e.firebaseio.com/turnos.json?auth=$authToken&orderBy="dni"&equalTo="$userDni"');
    if (response == null) return [];
    final turns = json.decode(response.body) as Map<String, dynamic>;
    turns.forEach((id, data) {
      Turn turn = Turn(
          id: id,
          hour: data["hora"],
          training: data["clase"],
          date: data["fecha"]);
      _turns.add(turn);
    });
    _turns.sort((turn1, turn2) => compareDates(turn1.date, turn2.date) * -1);
    return [..._turns];
  }

  Future<List<Turn>> getTurnsOfDay(String day, String training) async {
    final response = await http.get(
        'https://il-tempo-dda8e.firebaseio.com/turnos.json?auth=$authToken&orderBy="fecha"&equalTo="$day"');
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
      - 400: Error, user payment expired.
      - 401: Error, turn no longer available.
      - 404: Error, server side.
   */
  Future<int> createTurn({
    Training training,
    String dni,
    String name,
    String date,
    String hour,
  }) async {
    // Check if expired
    if(userExpireDate == null) return 400;
    if(userExpireDate.isBefore(DateTime.now().subtract(Duration(days: await expireMarginDays)))) return 400;
    // Check again if turn is available
    final List<Turn> turnsOfDay = await getTurnsOfDay(date, training.name);
    final int turnsOfHour =
        turnsOfDay.fold(0, (prev, turn) => turn.hour == hour ? prev + 1 : prev);
    if (turnsOfHour >= training.maxSchedules) return 401;
    // Create the turn
    final response = await http.post(
      "https://il-tempo-dda8e.firebaseio.com/turnos.json?auth=$authToken",
      body: json.encode({
        "dni": dni,
        "nombre": name,
        "clase": training.name,
        "fecha": date,
        "hora": hour,
      }),
    );
    newTurn = true;
    return response.statusCode == 200 ? 200 : 404;
  }

  Future<bool> cancelTurn(String id, String training) async {
    // Remove from DB
    final response = await http.delete(
        "https://il-tempo-dda8e.firebaseio.com/turnos/$id.json?auth=$authToken");
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
