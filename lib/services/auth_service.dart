import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// RegisterModel ve FirestoreService importları. Dosya yollarınızı kontrol edin.
import '../models/register_model.dart'; // RegisterModel'in doğru yolda olduğundan emin olun
import './firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final userId = userCredential.user!.uid;
        final userEmail = userCredential.user!.email!;

        final DocumentSnapshot<Map<String, dynamic>>? userDoc =
            await _firestoreService.getUserData(userId);

        if (userDoc == null || !userDoc.exists) {
          print(
            'Mevcut kullanıcı için Firestore dokümanı bulunamadı, temel bilgilerle oluşturuluyor: $userId',
          );
          // Giriş yapan ama Firestore'da olmayan kullanıcı için temel/varsayılan bilgilerle profil oluşturuyoruz.
          // Bu kullanıcıların profillerini daha sonra güncellemeleri gerekebilir.
          String defaultFirstName = 'Kullanıcı';
          String defaultLastName = '';
          // Firebase Auth'dan displayName alınabiliyorsa, onu kullanmayı deneyelim
          if (userCredential.user!.displayName != null &&
              userCredential.user!.displayName!.isNotEmpty) {
            List<String> nameParts = userCredential.user!.displayName!.split(
              ' ',
            );
            defaultFirstName = nameParts.first;
            if (nameParts.length > 1) {
              defaultLastName = nameParts.sublist(1).join(' ');
            }
          }

          await _firestoreService.saveUser(
            userId: userId,
            email: userEmail,
            // Zorunlu alanlar için varsayılan veya Auth'dan gelen bilgileri kullanıyoruz
            firstName: defaultFirstName,
            lastName: defaultLastName,
            dateOfBirth: DateTime(1900, 1, 1), // Genel bir varsayılan tarih
            gender: Gender.other, // Varsayılan cinsiyet
            displayNameFromModel:
                userCredential
                    .user!
                    .displayName, // displayNameFromModel olarak düzeltildi
            photoURL: userCredential.user!.photoURL,
          );
        } else {
          await _firestoreService.updateUserData(userId, {
            'lastLogin': FieldValue.serverTimestamp(),
          });
          print(
            'Mevcut kullanıcı için Firestore dokümanı bulundu, son giriş güncellendi: $userId',
          );
        }
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword({
    required RegisterModel registrationData,
  }) async {
    if (!registrationData.passwordsMatch) {
      throw Exception('Şifreler eşleşmiyor.');
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: registrationData.email,
        password: registrationData.password,
      );

      String displayNameForAuth =
          registrationData.displayName ??
          '${registrationData.firstName} ${registrationData.lastName}';
      if (displayNameForAuth.trim().isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayNameForAuth.trim());
      }
      // photoURL güncellemesi de eklenebilir.

      if (userCredential.user != null) {
        await _firestoreService.saveUser(
          userId: userCredential.user!.uid,
          email: userCredential.user!.email!,
          firstName: registrationData.firstName,
          lastName: registrationData.lastName,
          dateOfBirth: registrationData.dateOfBirth,
          gender: registrationData.gender,
          displayNameFromModel:
              displayNameForAuth
                  .trim(), // displayNameFromModel olarak kullanılıyor
          photoURL: userCredential.user!.photoURL,
        );
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Çıkış yapılırken hata: $e');
      throw Exception(
        'Çıkış yapılırken bir hata oluştu. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Email doğrulaması göndermek için önce giriş yapılmalı.');
    }
    if (user.emailVerified) {
      print('Email adresi zaten doğrulanmış.');
      return;
    }
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Hesap silmek için önce giriş yapılmalı.');
    }
    try {
      // await _firestoreService.deleteDocument(collectionPath: 'users', documentId: user.uid);
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Şifre güncellemek için önce giriş yapılmalı.');
    }
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    print('FirebaseAuthException [${e.code}]: ${e.message}');
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre girdiniz.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'weak-password':
        return 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin (en az 6 karakter).';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi formatı.';
      case 'operation-not-allowed':
        return 'E-posta/şifre ile kimlik doğrulama şu anda etkin değil.';
      case 'too-many-requests':
        return 'Çok fazla başarısız deneme yapıldı. Lütfen hesabınızı korumak için bir süre sonra tekrar deneyin.';
      case 'requires-recent-login':
        return 'Bu işlem hassas olduğu için yakın zamanda tekrar giriş yapmanız gerekmektedir.';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
      default:
        return 'Bir kimlik doğrulama hatası oluştu. Lütfen daha sonra tekrar deneyin.';
    }
  }
}
