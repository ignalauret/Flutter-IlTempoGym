import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:iltempo/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends ChangeNotifier {
  String _token;
  String _refreshToken;
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
      _refreshToken = responseData["refreshToken"];
      _userId = responseData["localId"];
      _expireDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData["expiresIn"])));
      await fetchUserData();
      _autoLogOut();
      notifyListeners();
      saveToPrefs();
      return "";
    } on HttpException catch (error) {
      return error.toString();
    }
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': _token,
      'refreshToken': _refreshToken,
      'userId': _userId,
      'userDni': _userDni,
      'userName': _userName,
      'expireDate': _expireDate.toIso8601String()
    });
    prefs.setString('userData', userData);
  }

//  void printData() {
//    print('token: $_token');
//    print('userId: $_userId,');
//    print('userDni: $_userDni,');
//    print('userName: $_userName,');
//    print('expireDate: $_expireDate.toIso8601String()');
//  }

  Future<bool> tryAutoLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      print("No user data");
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedUserData['expireDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      // If the token has expired, I try to refresh it with the refreshToken.
      final response = await http.post(
        "https://securetoken.googleapis.com/v1/token?key=AIzaSyDMsEID7PGSNpM5EySROO3iA-eUhcO_KPo",
        body: json.encode({
          "grant_type": "refresh_token",
          "refresh_token": extractedUserData["refreshToken"],
        }),
      );
      final userData = json.decode(response.body);
      print(userData);
      if (response.statusCode == 200) {
        // If i am successful, log in.
        final newExpiryDate = DateTime.now()
            .add(Duration(seconds: int.parse(userData["expiresIn"])));
        _token = userData["id_token"];
        _refreshToken = userData["refresh_token"];
        _userId = extractedUserData["userId"];
        _expireDate = newExpiryDate;
        _userDni = extractedUserData["userDni"];
        _userName = extractedUserData["userName"];
        notifyListeners();
        saveToPrefs();
        _autoLogOut();
        return true;
      } else {
        print("Failed refresh");
        return false;
      }
    }
    // If it hasn't expired, log in.
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
