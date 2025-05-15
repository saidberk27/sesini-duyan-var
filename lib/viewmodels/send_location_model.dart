// send_location_model.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences için eklendi

import '../models/location_data_model.dart';
import '../services/firestore_service.dart';

// SharedPreferences'ta userId'yi saklamak için kullanılacak anahtar
// Bu anahtar main.dart'taki callbackDispatcher içinde de kullanılacak.
const String userIdSharedPrefKey = 'current_user_id_for_background';

class SendLocationViewModel extends ChangeNotifier {
  String _konumBilgisiMesaji = "Konum bilgisi bekleniyor...";
  bool _isInitializing = true;
  bool _isFetchingLocation = false;
  bool _isUploadingLocation = false;

  final FirestoreService _firestore = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authStateSubscription;

  double? _latitude;
  double? _longitude;
  String? _currentUserId;

  String get konumBilgisi => _konumBilgisiMesaji;
  bool get isInitializing => _isInitializing;
  bool get isFetchingLocation => _isFetchingLocation;
  bool get isUploadingLocation => _isUploadingLocation;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get currentUserId => _currentUserId;

  SendLocationViewModel() {
    print("SendLocationViewModel oluşturuldu.");
    _initializeViewModel();
  }

  Future<void> _initializeViewModel() async {
    print("ViewModel başlatılıyor: Kullanıcı oturumu dinlenecek...");
    _isInitializing = true;
    _konumBilgisiMesaji = "Kullanıcı oturumu kontrol ediliyor...";
    notifyListeners();

    _authStateSubscription = _auth.authStateChanges().listen((
      User? user,
    ) async {
      print("Auth durumu değişti. Yeni Firebase kullanıcısı: ${user?.uid}");
      _currentUserId = user?.uid;
      final prefs = await SharedPreferences.getInstance();

      if (_currentUserId != null) {
        // Kullanıcı giriş yaptı, UID'yi SharedPreferences'a kaydet
        await prefs.setString(userIdSharedPrefKey, _currentUserId!);
        print("Kullanıcı ID ($currentUserId) SharedPreferences'a kaydedildi.");
        _konumBilgisiMesaji = "Kullanıcı oturumu aktif ($_currentUserId).";
        if (_isInitializing || !_isFetchingLocation) {
          print("Auth durumu aktif, ilk getKonum çağrılıyor...");
          await getKonum(isInitialCall: true);
        }
      } else {
        // Kullanıcı çıkış yaptı, UID'yi SharedPreferences'tan sil
        await prefs.remove(userIdSharedPrefKey);
        print("Kullanıcı ID SharedPreferences'tan silindi.");
        _konumBilgisiMesaji =
            "Giriş yapmış kullanıcı bulunamadı. Konum göndermek için lütfen giriş yapın.";
        print("Kullanıcı oturumu kapalı.");
      }
      _isInitializing = false; // Auth state geldi, başlatma tamamlandı.
      notifyListeners();
    });

    // Dinleyici hemen tetiklenmezse diye mevcut kullanıcıyı da kontrol et
    User? initialUser = _auth.currentUser;
    if (initialUser != null && _currentUserId == null) {
      // Listener henüz _currentUserId'yi set etmediyse
      print(
        "Başlangıçta aktif Firebase kullanıcısı bulundu: ${initialUser.uid}",
      );
      _currentUserId = initialUser.uid;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(userIdSharedPrefKey, _currentUserId!);
      print(
        "Başlangıç Kullanıcı ID ($currentUserId) SharedPreferences'a kaydedildi.",
      );
      _konumBilgisiMesaji = "Kullanıcı oturumu aktif ($_currentUserId).";
      if (_isInitializing || !_isFetchingLocation) {
        print("Başlangıçta aktif kullanıcı için ilk getKonum çağrılıyor...");
        await getKonum(isInitialCall: true);
      }
      _isInitializing = false;
      notifyListeners();
    } else if (initialUser == null &&
        _currentUserId == null &&
        _isInitializing) {
      // Başlangıçta kullanıcı yok ve listener da henüz tetiklenmediyse
      _isInitializing = false;
      _konumBilgisiMesaji = "Giriş yapmış kullanıcı bulunamadı.";
      final prefs =
          await SharedPreferences.getInstance(); // Emin olmak için sil
      await prefs.remove(userIdSharedPrefKey);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    print("SendLocationViewModel dispose ediliyor.");
    _authStateSubscription?.cancel();
    super.dispose();
  }

  // Kullanıcının manuel olarak çıkış yapması için bir metod
  Future<void> signOut() async {
    print("signOut metodu çağrıldı.");
    await _auth
        .signOut(); // Firebase'den çıkış yapar, bu _authStateSubscription'ı tetikler.
    // _authStateSubscription içindeki logic SharedPreferences'ı temizleyecektir.
    // _currentUserId otomatik olarak null olur ve notifyListeners çağrılır.
    // Ekstra bir SharedPreferences temizliği veya _currentUserId = null ataması burada gerekmez,
    // çünkü authStateChanges dinleyicisi bunu halleder.
    // Ancak, hemen UI güncellemesi için _konumBilgisiMesaji'nı set edebiliriz:
    _konumBilgisiMesaji = "Çıkış yapıldı. Tekrar giriş yapınız.";
    notifyListeners(); // UI'ı hemen güncellemek için
  }

  Future<void> getKonum({bool isInitialCall = false}) async {
    print(
      "getKonum fonksiyonu çağrıldı. UserID: $_currentUserId. İlk çağrı: $isInitialCall",
    );

    if (_isInitializing && !isInitialCall) {
      print("getKonum: ViewModel hala başlatılıyor, işlem ertelendi.");
      _konumBilgisiMesaji = "ViewModel başlatılıyor, lütfen bekleyin...";
      notifyListeners();
      return;
    }

    if (_isFetchingLocation && !isInitialCall) {
      print("Zaten devam eden bir konum alma işlemi var.");
      return;
    }

    if (_currentUserId == null || _currentUserId!.isEmpty) {
      _konumBilgisiMesaji =
          "KONUM GÖNDERİLEMEDİ: Geçerli bir kullanıcı oturumu bulunamadı. Lütfen giriş yapın.";
      print("HATA: getKonum çağrıldı ancak _currentUserId null veya boş.");
      notifyListeners();
      return;
    }

    _isFetchingLocation = true;
    _konumBilgisiMesaji = "Konum alınıyor...";
    notifyListeners();

    try {
      await requestBackgroundLocationPermission();
      bool servisAktif = await Geolocator.isLocationServiceEnabled();
      if (!servisAktif) {
        _konumBilgisiMesaji = "Konum servisi kapalı. Lütfen açın.";
        _isFetchingLocation = false;
        notifyListeners();
        return;
      }
      LocationPermission izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
        if (izin == LocationPermission.denied) {
          _konumBilgisiMesaji = "Konum izni verilmedi.";
          _isFetchingLocation = false;
          notifyListeners();
          return;
        }
      }
      if (izin == LocationPermission.deniedForever) {
        _konumBilgisiMesaji =
            "Konum izni kalıcı olarak reddedildi. Lütfen uygulama ayarlarından izin verin.";
        _isFetchingLocation = false;
        notifyListeners();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _latitude = position.latitude;
      _longitude = position.longitude;
      _konumBilgisiMesaji =
          "Enlem: ${_latitude?.toStringAsFixed(5)}, Boylam: ${_longitude?.toStringAsFixed(5)}";
      notifyListeners();

      _isUploadingLocation = true;
      _konumBilgisiMesaji += "\nFirestore'a gönderiliyor...";
      notifyListeners();

      // LocationDataModel'den deviceId alanı kaldırıldıysa, aşağıdaki gibi olmalı:
      final locationData = LocationDataModel(
        latitude: _latitude!,
        longitude: _longitude!,
        timestamp: Timestamp.now(),
        userId: _currentUserId!,
        // deviceId: null, // Bu satır ya null olur ya da modelden tamamen kaldırılır.
      );
      debugPrint(
        "Firestore'a Gönderilecek Model: UserID: ${locationData.userId}, Lat: ${locationData.latitude}, Lon: ${locationData.longitude}",
      );

      await _firestore.updateUserLocationAsFields(locationData);

      _konumBilgisiMesaji =
          "Enlem: ${_latitude?.toStringAsFixed(5)}, Boylam: ${_longitude?.toStringAsFixed(5)}\n(Konumunuz başarıyla güncellendi)";
      print("Konum başarıyla Firestore'a gönderildi.");
    } catch (e) {
      print("getKonum sırasında bir hata oluştu: $e");
      _konumBilgisiMesaji =
          "Konum gönderilirken bir hata oluştu: ${e.toString().substring(0, (e.toString().length > 100) ? 100 : e.toString().length)}...";
    } finally {
      _isFetchingLocation = false;
      _isUploadingLocation = false;
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    // ... (Bu metodun içeriği aynı kalabilir) ...
    print("getCurrentLocation çağrıldı");
    _isFetchingLocation = true;
    _konumBilgisiMesaji = "Anlık konum alınıyor...";
    notifyListeners();
    try {
      bool servisAktif = await Geolocator.isLocationServiceEnabled();
      if (!servisAktif) {
        _konumBilgisiMesaji = "Konum servisi kapalı.";
        _latitude = null;
        _longitude = null;
        _isFetchingLocation = false;
        notifyListeners();
        return;
      }
      LocationPermission izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied ||
          izin == LocationPermission.deniedForever) {
        izin = await Geolocator.requestPermission();
        if (izin == LocationPermission.denied ||
            izin == LocationPermission.deniedForever) {
          _konumBilgisiMesaji = "Konum izni yok.";
          _latitude = null;
          _longitude = null;
          _isFetchingLocation = false;
          notifyListeners();
          return;
        }
      }
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _latitude = position.latitude;
      _longitude = position.longitude;
      _konumBilgisiMesaji =
          "Anlık Konum: ${_latitude?.toStringAsFixed(5)}, ${_longitude?.toStringAsFixed(5)}";
    } catch (e) {
      _konumBilgisiMesaji = "Anlık konum alınamadı.";
      _latitude = null;
      _longitude = null;
    }
    _isFetchingLocation = false;
    notifyListeners();
  }
}

Future<void> requestBackgroundLocationPermission() async {
  // ... (Bu fonksiyon aynı kalabilir) ...
  var status = await Permission.locationAlways.status;
  if (!status.isGranted) {
    await Permission.locationAlways.request();
  }
}
