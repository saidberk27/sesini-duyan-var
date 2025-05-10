import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// RegisterModel ve Gender enum'ını import etmemiz gerekiyor.
// Dosya yolunuzun doğru olduğundan emin olun.
import '../models/register_model.dart';

class RegisterViewModel extends ChangeNotifier {
  // RegisterModel için gerekli alanlar
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  DateTime?
  _dateOfBirth; // Doğum tarihi nullable olabilir, kullanıcı seçene kadar
  Gender? _gender; // Cinsiyet nullable

  // ViewModel durumu için alanlar
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  DateTime? get dateOfBirth => _dateOfBirth;
  Gender? get gender => _gender;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Setters
  set firstName(String value) {
    _firstName = value.trim();
    _clearErrorMessage(); // Hata mesajını temizle
    notifyListeners();
  }

  set lastName(String value) {
    _lastName = value.trim();
    _clearErrorMessage();
    notifyListeners();
  }

  set email(String value) {
    _email = value.trim();
    _clearErrorMessage();
    notifyListeners();
  }

  set password(String value) {
    _password = value; // Şifrelerde trim yapmayalım
    _clearErrorMessage();
    notifyListeners();
  }

  set confirmPassword(String value) {
    _confirmPassword = value; // Şifrelerde trim yapmayalım
    _clearErrorMessage();
    notifyListeners();
  }

  set dateOfBirth(DateTime? value) {
    _dateOfBirth = value;
    _clearErrorMessage();
    notifyListeners();
  }

  set gender(Gender? value) {
    _gender = value;
    _clearErrorMessage();
    notifyListeners();
  }

  void _clearErrorMessage() {
    if (_errorMessage != null) {
      _errorMessage = null;
      // notifyListeners(); // Hata mesajı temizlendiğinde hemen UI güncellemesi gerekmeyebilir,
      // bir sonraki işlemde zaten güncellenecektir.
      // Ancak anında temizlenmesini isterseniz bu satırı açabilirsiniz.
    }
  }

  Future<UserCredential?> register() async {
    // Temel doğrulamalar
    if (_firstName.isEmpty ||
        _lastName.isEmpty ||
        _email.isEmpty ||
        _password.isEmpty ||
        _confirmPassword.isEmpty) {
      _errorMessage = "Lütfen tüm zorunlu alanları doldurun.";
      notifyListeners();
      return null;
    }
    if (_dateOfBirth == null) {
      _errorMessage = "Lütfen doğum tarihinizi seçin.";
      notifyListeners();
      return null;
    }
    // Cinsiyet zorunluysa buraya da bir kontrol eklenebilir:
    if (_gender == null) {
      _errorMessage = "Lütfen cinsiyetinizi seçin.";
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
      // RegisterModel nesnesini oluşturuyoruz
      final registrationData = RegisterModel(
        email: _email,
        password: _password,
        confirmPassword: _confirmPassword,
        firstName: _firstName,
        lastName: _lastName,
        dateOfBirth: _dateOfBirth!, // Yukarıda null kontrolü yaptık
        gender: _gender!, // Nullable olduğu için doğrudan geçebiliriz
        // displayName'i burada oluşturup gönderebiliriz veya AuthService'in oluşturmasına izin verebiliriz.
        // AuthService zaten firstName ve lastName'den oluşturuyor.
        // displayName: '$_firstName $_lastName',
      );

      // AuthService'in createUserWithEmailAndPassword metodunu çağırıyoruz
      final userCredential = await AuthService().createUserWithEmailAndPassword(
        registrationData: registrationData,
      );

      _isLoading = false;
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      // AuthService içindeki _handleAuthException daha detaylı mesajlar üretiyor.
      // Onu kullanmak daha iyi olabilir veya buradaki mesajları koruyabilirsiniz.
      // _errorMessage = AuthService()._handleAuthException(e); // Bu doğrudan çalışmaz çünkü _handleAuthException private.
      // AuthService'den dönen hatayı kullanmak için:
      // throw e; // ve UI katmanında AuthService'in fırlattığı hatayı yakala
      // Ya da burada kendi mesajlarınızı oluşturun:
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
      // AuthService'den gelen "Şifreler eşleşmiyor" gibi özel Exception'ları da yakalar.
      _errorMessage = 'Beklenmedik bir hata oluştu: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
}
