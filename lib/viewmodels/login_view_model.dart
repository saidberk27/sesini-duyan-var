import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthResult {
  final UserCredential? userCredential;
  final String? errorMessage;
  final bool isSuccess;

  AuthResult.success(this.userCredential)
      : errorMessage = null,
        isSuccess = true;

  AuthResult.error(this.errorMessage)
      : userCredential = null,
        isSuccess = false;
}

class LoginViewModel extends ChangeNotifier {
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  set email(String value) {
    _email = value;
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

Future<UserCredential?> login() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await AuthService().signInWithEmailAndPassword(
        email: _email, 
        password: _password
      );
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null; // Hata durumunda null dön
    }
}
}


