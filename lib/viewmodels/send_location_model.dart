import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_data_model.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SendLocationViewModel extends ChangeNotifier {
  // --- Durum Değişkenleri ---
  String _konumBilgisiMesaji = "Konum bilgisi bekleniyor...";
  bool _isInitializing = true;
  bool _isFetchingLocation = false;
  bool _isUploadingLocation = false;

  // --- Servisler ve Kimlikler ---
  final FirestoreService _firestore = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth örneği

  double? _latitude;
  double? _longitude;
  String? _currentUserId; // Giriş yapmış kullanıcının Firebase UID'si

  // --- Getter'lar ---
  String get konumBilgisi => _konumBilgisiMesaji;
  bool get isInitializing => _isInitializing;
  bool get isFetchingLocation => _isFetchingLocation;
  bool get isUploadingLocation => _isUploadingLocation;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get currentUserId =>
      _currentUserId; // Bu, giriş yapmış kullanıcının UID'si olacak

  // --- Constructor ---
  SendLocationViewModel() {
    print("SendLocationViewModel oluşturuldu.");
    _initializeViewModel();
  }

  // --- Başlatma Metodu (GÜNCELLENDİ: userId doğrudan Auth'dan alınacak) ---
  Future<void> _initializeViewModel() async {
    print("ViewModel başlatılıyor: Kullanıcı oturumu kontrol edilecek...");
    _isInitializing = true;
    _konumBilgisiMesaji = "Kullanıcı oturumu kontrol ediliyor...";
    notifyListeners();

    // 1. Kullanıcı ID'sini (UID) doğrudan Firebase Authentication'dan al
    User? user = _auth.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      print("Giriş yapmış kullanıcı ID'si (UID) alındı: $_currentUserId");
      // Kullanıcı ID'si alındıktan sonra ilk konumu almayı deneyebiliriz.
      _konumBilgisiMesaji = "Kullanıcı oturumu aktif. İlk konum alınıyor...";
      notifyListeners();
      await getKonum(isInitialCall: true);
    } else {
      _currentUserId = null;
      _konumBilgisiMesaji =
          "Giriş yapmış kullanıcı bulunamadı. Konum göndermek için lütfen giriş yapın.";
      print("Kullanıcı girişi yapılmamış.");
      // Bu durumda getKonum'u çağırmıyoruz veya UI'da bir uyarı gösteriyoruz.
    }

    _isInitializing = false;
    // notifyListeners() zaten getKonum içinde veya yukarıdaki if/else bloklarında çağrılıyor.
    // Eğer getKonum çağrılmadıysa, son mesajın UI'a yansıması için burada bir kez daha çağrılabilir.
    if (_currentUserId == null) {
      notifyListeners();
    }
  }

  // --- Ana Konum Alma ve Firestore'a Gönderme Metodu ---
  Future<void> getKonum({bool isInitialCall = false}) async {
    print("getKonum fonksiyonu çağrıldı. İlk çağrı: $isInitialCall");

    if (_isInitializing && !isInitialCall) {
      // Eğer hala başlatılıyorsa ve bu ilk çağrı değilse bekleme
      print("getKonum: ViewModel hala başlatılıyor, bekleniyor.");
      await Future.delayed(const Duration(milliseconds: 200));
      if (_isInitializing) {
        // Hala başlatılıyorsa çık
        print("getKonum: Başlatma hala bitmedi, çıkılıyor.");
        return;
      }
    }

    if (_isFetchingLocation && !isInitialCall) {
      print("Zaten devam eden bir konum alma işlemi var.");
      return;
    }

    // Kullanıcı ID'si kesinlikle olmalı (giriş yapmış kullanıcı senaryosu)
    // _initializeViewModel'de bu kontrol yapıldı ve userId null ise getKonum çağrılmıyor (veya uyarı veriliyor).
    // Yine de bir güvenlik önlemi olarak burada da kontrol edelim.
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      _konumBilgisiMesaji =
          "KONUM GÖNDERİLEMEDİ: Geçerli bir kullanıcı oturumu bulunamadı. Lütfen giriş yapın.";
      print("HATA: getKonum çağrıldı ancak _currentUserId null veya boş.");
      // _isFetchingLocation = false; // Eğer işlem başlamadan bitiyorsa
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

      print("Geolocator.getCurrentPosition çağrılıyor...");
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      print(
        "Konum başarıyla alındı: Lat: ${position.latitude}, Lon: ${position.longitude}",
      );

      _latitude = position.latitude;
      _longitude = position.longitude;
      _konumBilgisiMesaji =
          "Enlem: ${_latitude?.toStringAsFixed(5)}, Boylam: ${_longitude?.toStringAsFixed(5)}";
      notifyListeners();

      _isUploadingLocation = true;
      _konumBilgisiMesaji += "\nFirestore'a gönderiliyor...";
      notifyListeners();

      // LocationDataModel oluşturulurken deviceId artık gönderilmiyor (veya null gönderiliyor)
      // Modelinizdeki deviceId alanını nullable (String?) yapın veya kaldırın.
      // Şimdilik null gönderdiğimizi varsayalım, FirestoreService bunu ele alacaktır.
      final locationData = LocationDataModel(
        latitude: _latitude!,
        longitude: _longitude!,
        timestamp: Timestamp.now(),
        userId: _currentUserId!, // Giriş yapmış kullanıcının UID'si
      );

      debugPrint(
        "Firestore'a Gönderilecek Model: UserID: ${locationData.userId}}, Lat: ${locationData.latitude}, Lon: ${locationData.longitude}",
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

  // --- Mevcut getCurrentLocation Metodunuz (Sadece konumu alır, göndermez) ---
  Future<void> getCurrentLocation() async {
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
      print("Anlık konum başarıyla alındı: Lat: $_latitude, Lon: $_longitude");
    } catch (e) {
      print("getCurrentLocation sırasında hata: $e");
      _konumBilgisiMesaji = "Anlık konum alınamadı.";
      _latitude = null;
      _longitude = null;
    }
    _isFetchingLocation = false;
    notifyListeners();
  }
} // SendLocationViewModel sınıfının sonu

// --- Arka Plan Konum İzni İsteme Fonksiyonu ---
Future<void> requestBackgroundLocationPermission() async {
  var status = await Permission.locationAlways.status;
  if (!status.isGranted) {
    print("Arka plan konum izni isteniyor...");
    var result = await Permission.locationAlways.request();
    if (result.isGranted) {
      print("Arka plan konum izni verildi.");
    } else if (result.isPermanentlyDenied) {
      print("Arka plan konum izni kalıcı olarak reddedildi.");
    } else {
      print("Arka plan konum izni reddedildi.");
    }
  } else {
    print("Arka plan konum izni zaten verilmiş.");
  }
}
