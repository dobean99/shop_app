import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool isAuth() {
    return _token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) return _token;
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    try {
      var url = Uri.parse(
          "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDbx6bzS53ZwgrEgj8BRMhaH5-oZ9qzczU");
      final response = await http.post(url,
          body: json.encode({
            "email": email,
            "password": password,
            "returnSecureToken": true,
          }));
      final responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData',userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> logIn(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<void> logout() async{
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs= await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
  Future<bool> autoLogin ()async
  {
    final prefs= await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData'))
      return false;
    final userData= prefs.get('userData') as Map<String,Object>;
    final expiryDate=DateTime.parse(userData['expiryDate']);
    if(expiryDate.isBefore(DateTime.now()))
      return false;
    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate = DateTime(userData['expiryDate']);
    notifyListeners();
    _autoLogout();
    return true;
  }

}
