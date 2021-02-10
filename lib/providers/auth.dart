import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:iltempo/models/http_exception.dart';
import 'package:iltempo/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends ChangeNotifier {
  String _token;

  String _refreshToken;
  DateTime _expireDate;
  Timer _authTimer;
  // User data
  String _userId;
  String _userName;
  String _userDni;
  String _userExpireDate;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get userExpireDate {
    return _userExpireDate;
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
    return _userName ?? "Cargando...";
  }

  String get userDni {
    return _userDni ?? "Cargando...";
  }

  Future<void> fetchUserData() async {
    final response = await http.get(
        kFirebaseUrl + "/usuarios/$_userId.json?auth=$_token");
    if(response.statusCode == 200) {
      final responseData = json.decode(response.body);
      _userName = responseData["nombre"];
      _userDni = responseData["dni"].toString();
      _userExpireDate = responseData['vencimiento'];
    }
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
      'expireDate': _expireDate.toIso8601String()
    });
    prefs.setString('userData', userData);
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
      // If the token has expired, I try to refresh it with the refreshToken.
      final response = await http.post(
        "https://securetoken.googleapis.com/v1/token?key=AIzaSyDMsEID7PGSNpM5EySROO3iA-eUhcO_KPo",
        body: json.encode({
          "grant_type": "refresh_token",
          "refresh_token": extractedUserData["refreshToken"],
        }),
      );
      final userData = json.decode(response.body);
      if (response.statusCode == 200) {
        // If i am successful, log in.
        final newExpiryDate = DateTime.now()
            .add(Duration(seconds: int.parse(userData["expires_in"])));
        _token = userData["access_token"];
        _refreshToken = userData["refresh_token"];
        _userId = extractedUserData["userId"];
        _expireDate = newExpiryDate;
        await fetchUserData();
        notifyListeners();
        saveToPrefs();
        return true;
      } else {
        return false;
      }
    }
    // If it hasn't expired, log in.
    _token = extractedUserData['token'];
    _refreshToken = extractedUserData['refreshToken'];
    _userId = extractedUserData['userId'];
    _expireDate = expiryDate;
    await fetchUserData();
    notifyListeners();
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
}
