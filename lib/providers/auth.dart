import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:iltempo/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends ChangeNotifier {
  String _token;
  DateTime _expireDate;
  String _userId;
  String _userName;
  String _userDni;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expireDate != null &&
        _expireDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userName {
    return _userName == null ? "Nombre default" : _userName;
  }

  String get userDni {
    return _userDni == null ? "12345678" : _userDni;
  }

  Future<void> fetchUserData() async {
    final response = await http.get(
        "https://il-tempo-dda8e.firebaseio.com/usuarios/$_userId.json?auth=$_token");
    final responseData = json.decode(response.body);
    if (responseData == null) return;
    if (responseData["error"] != null) {
      // Hubo un error
      return;
    }

    _userName = responseData["nombre"];
    _userDni = responseData["dni"].toString();
  }

  Future<String> logIn(String username, String password) async {
    final email = username + "@iltempo.com";
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyDMsEID7PGSNpM5EySROO3iA-eUhcO_KPo";
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            "email": email,
            "password": password,
            "returnSecureToken": true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      _token = responseData["idToken"];
      _userId = responseData["localId"];
      _expireDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData["expiresIn"])));
      await fetchUserData();
      _autoLogOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'userDni': _userDni,
        'userName': _userName,
        'expireDate': _expireDate.toIso8601String()
      });
      prefs.setString('userData', userData);
      return "";
    } on HttpException catch (error) {
      return error.toString();
    }
  }

  void printData() {
    print('token: $_token');
    print('userId: $_userId,');
    print('userDni: $_userDni,');
    print('userName: $_userName,');
    print('expireDate: $_expireDate.toIso8601String()');
  }

  Future<bool> tryAutoLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedUserData['expireDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _userName = extractedUserData['userName'];
    _expireDate = expiryDate;
    _userDni = extractedUserData['userDni'];
    notifyListeners();
    _autoLogOut();
    return true;
  }

  Future<void> logOut() async {
    _token = null;
    _userDni = null;
    _userName = null;
    _userId = null;
    _expireDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  void _autoLogOut() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final seconds = _expireDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: seconds), logOut);
  }
}
