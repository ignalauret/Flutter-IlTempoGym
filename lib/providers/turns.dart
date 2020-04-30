import 'package:flutter/material.dart';
import '../models/turn.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Turns extends ChangeNotifier {
  Turns(this.authToken, this.userDni);

  final String authToken;
  final String userDni;

  List<Turn> _turns = [];

  Future<List<Turn>> getUsersTurns(List<String> urls) async {
    if (_turns.isNotEmpty) return [..._turns];
    for (var url in urls) {
      final response =
          await http.get(url + '&orderBy="dni"&equalTo="$userDni"');
      if (response == null) break;
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
    }
    return [..._turns];
  }

  Future<void> cancelTurn(String id, String training) async {
    var response;
    switch (training) {
      case "Musculacion":
        response = await http.delete(
            "https://il-tempo-dda8e.firebaseio.com/musculacion/$id.json?auth=$authToken");
        break;
      case "Spinning":
        response = await http.delete(
            "https://il-tempo-dda8e.firebaseio.com/spinning/$id.json?auth=$authToken");
        break;
      case "Zumba":
        response = await http.delete(
            "https://il-tempo-dda8e.firebaseio.com/zumba/$id.json?auth=$authToken");
        break;
    }
    _turns.removeWhere((turn) => turn.id == id);
    notifyListeners();
  }
}
