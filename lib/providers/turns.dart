import 'package:flutter/material.dart';
import 'package:iltempo/models/training.dart';
import 'package:iltempo/utils/utils.dart';
import '../models/turn.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Turns extends ChangeNotifier {
  Turns(this.authToken, this.userDni);

  final String authToken;
  final String userDni;
  bool _newTurn;

  set newTurn(bool turn) {
    _newTurn = turn;
    notifyListeners();
  }

  List<Turn> _turns = [];

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

  Future<bool> createTurn({
    Training training,
    String dni,
    String name,
    String date,
    String hour,
  }) async {
    // Check again if turn is available
    final List<Turn> turnsOfDay = await getTurnsOfDay(date, training.name);
    final int turnsOfHour =
        turnsOfDay.fold(0, (prev, turn) => turn.hour == hour ? prev + 1 : prev);
    if (turnsOfHour >= training.maxSchedules) return false;
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
    return response.statusCode == 200;
  }

  Future<bool> cancelTurn(String id, String training) async {
    // Remove from DB
    final response = await http.delete(
        "https://il-tempo-dda8e.firebaseio.com/turnos/$id.json?auth=$authToken");
    print(response.statusCode);
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
