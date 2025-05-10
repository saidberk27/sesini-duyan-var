import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Mevcut kullanıcıya erişmek için
// RegisterModel'i import ediyoruz. Dosya yolunuzu kontrol edin.
// Eğer models klasörü lib altındaysa:
import '../models/register_model.dart';
// Eğer models klasörü services ile aynı seviyedeyse (lib/services, lib/models):
// import '../models/register_model.dart'; // Bu yol doğru olabilir
// Eğer models klasörü lib/core/models gibi bir yerdeyse:
// import '../../core/models/register_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Yaş hesaplama fonksiyonu
  int _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }
    return age < 0 ? 0 : age; // Negatif yaş olmaması için kontrol
  }

  Future<void> saveUser({
    required String userId,
    required String email,
    // RegisterModel'den gelen diğer bilgileri de alacağız.
    // Bu metodun imzası artık daha genel olabilir veya doğrudan RegisterModel alabilir.
    // Şimdilik ayrı parametreler olarak bırakalım, AuthService'den bu şekilde çağıracağız.
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required Gender gender,
    String? displayNameFromModel, // RegisterModel'den gelen displayName
    String? photoURL, // Bu hala genel bir parametre olarak kalabilir
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final DocumentReference userDocRef = _firestore
          .collection('users')
          .doc(userId);

      // Yaşı hesapla
      final int age = _calculateAge(dateOfBirth);

      // displayName'i oluştur: Eğer modelden gelmiyorsa ad ve soyaddan oluştur.
      final String displayName = displayNameFromModel ?? '$firstName $lastName';

      final Map<String, dynamic> userData = {
        'uid': userId,
        'email': email.toLowerCase(),
        'displayName': displayName.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'dateOfBirth': Timestamp.fromDate(
          dateOfBirth,
        ), // DateTime'ı Timestamp'e çevir
        'age': age, // Hesaplanan yaş
        'gender':
            gender
                .toString()
                .split('.')
                .last, // Enum'ı string'e çevir (örn: "male")
        'photoURL': photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      };

      if (additionalData != null) {
        userData.addAll(additionalData);
      }

      await userDocRef.set(userData);
      print(
        'Kullanıcı verisi (detaylı) başarıyla Firestore\'a kaydedildi: $userId',
      );
    } on FirebaseException catch (e) {
      print('Firestore kullanıcı kaydetme hatası: ${e.code} - ${e.message}');
      throw Exception('Kullanıcı verileri kaydedilirken bir sorun oluştu.');
    } catch (e) {
      print('Genel kullanıcı kaydetme hatası: $e');
      throw Exception('Beklenmedik bir hata oluştu.');
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserData(
    String userId,
  ) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc;
      } else {
        print('Kullanıcı dokümanı bulunamadı: $userId');
        return null;
      }
    } on FirebaseException catch (e) {
      print(
        'Firestore kullanıcı verisi getirme hatası: ${e.code} - ${e.message}',
      );
      throw Exception('Kullanıcı verileri getirilirken bir sorun oluştu.');
    } catch (e) {
      print('Genel kullanıcı verisi getirme hatası: $e');
      throw Exception('Beklenmedik bir hata oluştu.');
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getCurrentUserData() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return await getUserData(currentUser.uid);
    }
    return null;
  }

  Future<void> updateUserData(
    String userId,
    Map<String, Object?> dataToUpdate,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update(dataToUpdate);
      print('Kullanıcı verisi başarıyla güncellendi: $userId');
    } on FirebaseException catch (e) {
      print('Firestore kullanıcı güncelleme hatası: ${e.code} - ${e.message}');
      throw Exception('Kullanıcı verileri güncellenirken bir sorun oluştu.');
    } catch (e) {
      print('Genel kullanıcı güncelleme hatası: $e');
      throw Exception('Beklenmedik bir hata oluştu.');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCollectionStream(
    String collectionPath,
  ) {
    return _firestore.collection(collectionPath).snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> addDocumentToCollection({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    try {
      final dataWithTimestamp = {
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      };
      final CollectionReference<Map<String, dynamic>> typedCollectionRef =
          _firestore.collection(collectionPath);
      final DocumentReference<Map<String, dynamic>> docRef =
          await typedCollectionRef.add(dataWithTimestamp);
      print('"$collectionPath" koleksiyonuna doküman eklendi: ${docRef.id}');
      return docRef;
    } on FirebaseException catch (e) {
      print(
        'Firestore doküman ekleme hatası ($collectionPath): ${e.code} - ${e.message}',
      );
      throw Exception('Veri eklenirken bir sorun oluştu.');
    } catch (e) {
      print('Genel doküman ekleme hatası ($collectionPath): $e');
      throw Exception('Beklenmedik bir hata oluştu.');
    }
  }

  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).delete();
      print('"$collectionPath/$documentId" dokümanı başarıyla silindi.');
    } on FirebaseException catch (e) {
      print(
        'Firestore doküman silme hatası ($collectionPath/$documentId): ${e.code} - ${e.message}',
      );
      throw Exception('Veri silinirken bir sorun oluştu.');
    } catch (e) {
      print('Genel doküman silme hatası ($collectionPath/$documentId): $e');
      throw Exception('Beklenmedik bir hata oluştu.');
    }
  }
}
