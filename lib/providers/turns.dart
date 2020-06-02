import 'package:flutter/material.dart';
import 'package:iltempo/models/training.dart';
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
          day: data["dia"],
          training: data["clase"],
          date: data["fecha"]);
      _turns.add(turn);
    });
    return [..._turns];
  }

  void createTurn(
      {Training training,
      String dni,
      String name,
      String day,
      String date,
      String hour}) {
    final url =
        "https://il-tempo-dda8e.firebaseio.com/turnos.json?auth=$authToken";
    http.post(
      url,
      body: json.encode({
        "dni": dni,
        "nombre": name,
        "clase": training.name,
        "dia": day,
        "fecha": date,
        "hora": hour,
      }),
    );
    newTurn = true;
  }

  Future<void> cancelTurn(String id, String training) async {
    // Remove from memory
    _turns.removeWhere((turn) => turn.id == id);
    // Remove from DB
    http.delete("https://il-tempo-dda8e.firebaseio.com/turnos/$id.json?auth=$authToken");
    notifyListeners();
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
          day: data["dia"],
          training: data["clase"],
          date: data["fecha"],
          dni: data["dni"],
        );
        result.add(turn);
      }
    });
    return result;
  }
}
