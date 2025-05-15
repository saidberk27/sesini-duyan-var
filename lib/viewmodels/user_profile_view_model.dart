import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_data_model.dart'; // UserDataModel'i oluşturmanız gerekecek

class UserProfileViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserDataModel? _userData;
  UserDataModel? get userData => _userData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  UserProfileViewModel() {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (doc.exists && doc.data() != null) {
          _userData = UserDataModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          );
        } else {
          _errorMessage = "Kullanıcı verisi bulunamadı.";
        }
      } catch (e) {
        _errorMessage = "Kullanıcı verisi yüklenirken hata: ${e.toString()}";
      }
    } else {
      _errorMessage = "Giriş yapmış kullanıcı bulunamadı.";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateFirstName(String newFirstName) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    User? currentUser = _auth.currentUser;
    if (currentUser != null && _userData != null) {
      try {
        // Firestore'da 'firstName' alanını güncelle
        await _firestore.collection('users').doc(currentUser.uid).update({
          'firstName': newFirstName,
          // İsteğe bağlı: Eğer displayName'i "ad soyad" olarak tutuyorsanız, onu da güncelleyin:
          // 'displayName': '$newFirstName ${_userData!.lastName ?? ''}'.trim(),
        });

        // Yerel _userData modelini güncelle
        _userData = _userData!.copyWith(
          firstName: newFirstName,
          // displayName: '$newFirstName ${_userData!.lastName ?? ''}'.trim(), // Eğer displayName'i de güncelliyorsanız
        );
        _successMessage = "Adınız başarıyla güncellendi.";
      } catch (e) {
        _errorMessage = "Ad güncellenirken hata: ${e.toString()}";
      }
    } else {
      _errorMessage =
          "İşlem için kullanıcı girişi gerekli veya kullanıcı verisi yüklenmemiş.";
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Kullanıcının soyadını (lastName) Firestore'da ve yerel modelde günceller.
  Future<void> updateLastName(String newLastName) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    User? currentUser = _auth.currentUser;
    if (currentUser != null && _userData != null) {
      try {
        // Firestore'da 'lastName' alanını güncelle
        await _firestore.collection('users').doc(currentUser.uid).update({
          'lastName': newLastName,
          // İsteğe bağlı: Eğer displayName'i "ad soyad" olarak tutuyorsanız, onu da güncelleyin:
          // 'displayName': '${_userData!.firstName ?? ''} $newLastName'.trim(),
        });

        // Yerel _userData modelini güncelle
        _userData = _userData!.copyWith(
          lastName: newLastName,
          // displayName: '${_userData!.firstName ?? ''} $newLastName'.trim(), // Eğer displayName'i de güncelliyorsanız
        );
        _successMessage = "Soyadınız başarıyla güncellendi.";
      } catch (e) {
        _errorMessage = "Soyad güncellenirken hata: ${e.toString()}";
      }
    } else {
      _errorMessage =
          "İşlem için kullanıcı girişi gerekli veya kullanıcı verisi yüklenmemiş.";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateGender(String newGender) async {
    // Benzer şekilde gender güncelleme
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    User? currentUser = _auth.currentUser;
    if (currentUser != null && _userData != null) {
      try {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'gender': newGender,
        });
        _userData = _userData!.copyWith(gender: newGender);
        _successMessage = "Cinsiyet başarıyla güncellendi.";
      } catch (e) {
        _errorMessage = "Cinsiyet güncellenirken hata: ${e.toString()}";
      }
    } else {
      _errorMessage = "İşlem için kullanıcı girişi gerekli.";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateDateOfBirth(DateTime newDateOfBirth) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    User? currentUser = _auth.currentUser;
    if (currentUser != null && _userData != null) {
      try {
        // DateTime'ı Firestore Timestamp'ine çevir
        Timestamp newBirthTimestamp = Timestamp.fromDate(newDateOfBirth);

        // Firestore'da 'dateOfBirth' alanını güncelle
        await _firestore.collection('users').doc(currentUser.uid).update({
          'dateOfBirth': newBirthTimestamp,
        });

        // Yerel _userData modelini güncelle
        _userData = _userData!.copyWith(dateOfBirth: newBirthTimestamp);
        _successMessage = "Doğum tarihiniz başarıyla güncellendi.";
      } catch (e) {
        _errorMessage = "Doğum tarihi güncellenirken hata: ${e.toString()}";
      }
    } else {
      _errorMessage =
          "İşlem için kullanıcı girişi gerekli veya kullanıcı verisi yüklenmemiş.";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserEmail(String newEmail, String currentPassword) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        // Önce kullanıcıyı yeniden doğrula (güvenlik için)
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: currentPassword,
        );
        await currentUser.reauthenticateWithCredential(credential);

        // E-postayı Firebase Auth'da güncelle
        await currentUser.updateEmail(newEmail);
        // E-postayı Firestore'da da güncelle
        await _firestore.collection('users').doc(currentUser.uid).update({
          'email': newEmail,
        });
        if (_userData != null) {
          _userData = _userData!.copyWith(email: newEmail);
        }
        _successMessage =
            "E-posta adresiniz başarıyla güncellendi. Lütfen yeni e-postanızı doğrulayın.";
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          _errorMessage = 'Mevcut şifreniz yanlış.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage =
              'Bu e-posta adresi zaten başka bir hesap tarafından kullanılıyor.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'Geçersiz e-posta formatı.';
        } else if (e.code == 'requires-recent-login') {
          _errorMessage =
              'Bu işlem için kısa süre önce giriş yapmış olmanız gerekmektedir. Lütfen tekrar giriş yapın.';
        } else {
          _errorMessage =
              "E-posta güncellenirken bir Firebase Auth hatası oluştu: ${e.message}";
        }
      } catch (e) {
        _errorMessage = "E-posta güncellenirken hata: ${e.toString()}";
      }
    } else {
      _errorMessage = "İşlem için kullanıcı girişi gerekli.";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserPassword(
    String currentPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: currentPassword,
        );
        await currentUser.reauthenticateWithCredential(credential);
        await currentUser.updatePassword(newPassword);
        _successMessage = "Şifreniz başarıyla güncellendi.";
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          _errorMessage = 'Mevcut şifreniz yanlış.';
        } else if (e.code == 'weak-password') {
          _errorMessage = 'Yeni şifre çok zayıf.';
        } else if (e.code == 'requires-recent-login') {
          _errorMessage =
              'Bu işlem için kısa süre önce giriş yapmış olmanız gerekmektedir. Lütfen tekrar giriş yapın.';
        } else {
          _errorMessage =
              "Şifre güncellenirken bir Firebase Auth hatası oluştu: ${e.message}";
        }
      } catch (e) {
        _errorMessage = "Şifre güncellenirken hata: ${e.toString()}";
      }
    } else {
      _errorMessage = "İşlem için kullanıcı girişi gerekli.";
    }
    _isLoading = false;
    notifyListeners();
  }

  // Mesajları temizlemek için
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
