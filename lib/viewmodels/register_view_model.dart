import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isLoading = false;
  String? _errorMessage;

  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  set name(String value) {
    _name = value.trim();
    notifyListeners();
  }

  set email(String value) {
    _email = value.trim();
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  set confirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
  }

  Future<UserCredential?> register() async {
    if (_name.isEmpty ||
        _email.isEmpty ||
        _password.isEmpty ||
        _confirmPassword.isEmpty) {
      _errorMessage = "Tüm alanların doldurulması zorunludur.";
      notifyListeners();
      return null;
    }
    if (!_email.contains('@') || !_email.contains('.')) {
      _errorMessage = "Lütfen geçerli bir e-posta adresi girin.";
      notifyListeners();
      return null;
    }
    if (_password.length < 6) {
      _errorMessage = "Şifre en az 6 karakter olmalıdır.";
      notifyListeners();
      return null;
    }
    if (_password != _confirmPassword) {
      _errorMessage = "Girilen şifreler eşleşmiyor.";
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await AuthService().signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      if (userCredential != null &&
          userCredential.user != null &&
          _name.isNotEmpty) {
        await userCredential.user!.updateDisplayName(_name);

        await userCredential.user!.reload();
      }

      _isLoading = false;
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      if (e.code == 'weak-password') {
        _errorMessage = 'Girilen şifre çok zayıf.';
      } else if (e.code == 'email-already-in-use') {
        _errorMessage = 'Bu e-posta adresi ile zaten bir hesap mevcut.';
      } else {
        _errorMessage = 'Kayıt sırasında bir hata oluştu: ${e.message}';
      }
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Beklenmedik bir hata oluştu: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
}
