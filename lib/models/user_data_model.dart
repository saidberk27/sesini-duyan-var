// lib/models/user_data_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Yaş hesaplaması ve tarih formatlama için

class UserDataModel {
  final String
  uid; // Kullanıcının Firebase Auth UID'si, aynı zamanda doküman ID'si
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? photoURL;
  final String? gender;
  final Timestamp? dateOfBirth; // ALAN ADI GÜNCELLENDİ: dateOfBirth
  final Timestamp? createdAt; // Hesabın oluşturulma zamanı
  final Timestamp? lastLogin; // Son giriş zamanı
  final Timestamp? lastLocationUpdate; // Son konum güncelleme zamanı
  final GeoPoint? location; // Son bilinen konum (Firestore GeoPoint)

  UserDataModel({
    required this.uid,
    this.email,
    this.firstName,
    this.lastName,
    this.photoURL,
    this.gender,
    this.dateOfBirth, // Constructor'a eklendi
    this.createdAt,
    this.lastLogin,
    this.lastLocationUpdate,
    this.location,
  });

  /// Firestore'dan gelen DocumentSnapshot'ı UserDataModel nesnesine dönüştürür.
  factory UserDataModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError(
        'Firestore\'dan gelen kullanıcı verisi (snapshot.data()) null.',
      );
    }

    return UserDataModel(
      uid: snapshot.id,
      email: data['email'] as String?,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      photoURL: data['photoURL'] as String?,
      gender: data['gender'] as String?,
      dateOfBirth:
          data['dateOfBirth']
              as Timestamp?, // Firestore'dan okunuyor (alan adı güncellendi)
      createdAt: data['createdAt'] as Timestamp?,
      lastLogin: data['lastLogin'] as Timestamp?,
      lastLocationUpdate: data['lastLocationUpdate'] as Timestamp?,
      location: data['location'] as GeoPoint?,
    );
  }

  /// UserDataModel nesnesini Firestore'a yazmak için Map'e dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      if (email != null) 'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (photoURL != null) 'photoURL': photoURL,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null)
        'dateOfBirth':
            dateOfBirth, // Firestore'a yazılıyor (alan adı güncellendi)
      if (createdAt != null) 'createdAt': createdAt,
      if (lastLogin != null) 'lastLogin': lastLogin,
      if (lastLocationUpdate != null) 'lastLocationUpdate': lastLocationUpdate,
      if (location != null) 'location': location,
    };
  }

  /// Mevcut UserDataModel nesnesinin bir kopyasını oluşturur
  /// ve belirtilen alanları yeni değerleriyle günceller.
  UserDataModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? photoURL,
    String? gender,
    Timestamp? dateOfBirth, // copyWith'e eklendi (alan adı güncellendi)
    Timestamp? createdAt,
    Timestamp? lastLogin,
    Timestamp? lastLocationUpdate,
    GeoPoint? location,
  }) {
    return UserDataModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoURL: photoURL ?? this.photoURL,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      location: location ?? this.location,
    );
  }

  /// Doğum tarihinden yaşı hesaplayan bir getter.
  /// Eğer doğum tarihi yoksa null döndürür.
  int? get age {
    if (dateOfBirth == null) {
      // 'birthDate' yerine 'dateOfBirth' kullanılıyor
      return null;
    }
    final DateTime birthDateTime =
        dateOfBirth!.toDate(); // 'birthDate' yerine 'dateOfBirth' kullanılıyor
    final DateTime today = DateTime.now();

    int age = today.year - birthDateTime.year;
    if (birthDateTime.month > today.month ||
        (birthDateTime.month == today.month && birthDateTime.day > today.day)) {
      age--;
    }
    return age;
  }

  /// Doğum tarihini formatlı bir string olarak döndüren bir getter (isteğe bağlı).
  /// Örneğin: "15 Mayıs 1990"
  String? get formattedBirthDate {
    if (dateOfBirth == null) {
      // 'birthDate' yerine 'dateOfBirth' kullanılıyor
      return null;
    }
    final DateFormat formatter = DateFormat(
      'dd MMMM yyyy',
      'tr_TR',
    ); // Yıl için 'yyyy' eklendi
    return formatter.format(
      dateOfBirth!.toDate(),
    ); // 'birthDate' yerine 'dateOfBirth' kullanılıyor
  }
}
