import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/register_model.dart'; // RegisterModel import edildi
import '../models/location_data_model.dart'; // location_data_model.dart import edildi

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
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required Gender gender,
    String? displayNameFromModel,
    String? photoURL,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final DocumentReference userDocRef = _firestore
          .collection('users')
          .doc(userId);

      final int age = _calculateAge(dateOfBirth);
      final String displayName = displayNameFromModel ?? '$firstName $lastName';

      final Map<String, dynamic> userData = {
        'uid': userId,
        'email': email.toLowerCase(),
        'displayName': displayName.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'dateOfBirth': Timestamp.fromDate(dateOfBirth),
        'age': age,
        'gender': gender.toString().split('.').last,
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

  Future<void> updateUserLocationAsFields(
    LocationDataModel locationData,
  ) async {
    final String? userId = locationData.userId;

    try {
      final DocumentReference userDocRef = _firestore
          .collection('users')
          .doc(userId);

      await userDocRef.update({
        'location': GeoPoint(locationData.latitude, locationData.longitude),
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });

      print('Kullanıcının konumu başarıyla güncellendi.');
    } on FirebaseException catch (e) {
      print('Firestore konum güncelleme hatası: ${e.code} - ${e.message}');
      throw Exception('Konum güncellenirken bir sorun oluştu.');
    } catch (e) {
      print('Genel konum güncelleme hatası: $e');
      throw Exception('Beklenmedik bir hata oluştu.');
    }
  }
}
