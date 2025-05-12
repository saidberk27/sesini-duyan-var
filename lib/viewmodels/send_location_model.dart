import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_data_model.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

class SendLocationViewModel extends ChangeNotifier {
  String konumBilgisi = "Konum bilgisi alınmadı.";
  final FirestoreService _firestore = FirestoreService();

  double? _latitude;
  double? _longitude;

  double? get latitude => _latitude;
  double? get longitude => _longitude;

  Future<void> getKonum() async {
    print("getKonum fonksiyonu çağrıldı");
    await requestBackgroundLocationPermission();
    try {
      bool servisAktif = await Geolocator.isLocationServiceEnabled();
      if (!servisAktif) {
        konumBilgisi = "Konum servisi aktif değil.";
        notifyListeners();
        return;
      }

      LocationPermission izin = await Geolocator.checkPermission();

      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
        if (izin == LocationPermission.denied) {
          konumBilgisi = "Konum izni verilmedi.";
          notifyListeners();
          return;
        }
      }

      if (izin == LocationPermission.deniedForever) {
        konumBilgisi =
        "Konum izni kalıcı olarak reddedildi, ayarlardan izin verin.";
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

      String? userId =
          "test_user_id"; //_authService.currentUser?.uid; //sorunlu satır
      String deviceId =
          userId ?? DateTime.now().millisecondsSinceEpoch.toString();

      final locationData = LocationDataModel(
        latitude: _latitude!,
        longitude: _longitude!,
        timestamp: Timestamp.now(),
        userId: userId,
        deviceId: deviceId,
      );

      debugPrint(
          "Lokasyon:  ${locationData.longitude} ${locationData.latitude}");
      await _firestore.recordLocationDataModel(locationData);

      konumBilgisi = "Enlem: $_latitude, Boylam: $_longitude";
      notifyListeners();
    } catch (e) {
      konumBilgisi = "Konum alınırken veya kaydedilirken hata oluştu: $e";
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _latitude = position.latitude;
      _longitude = position.longitude;
      notifyListeners();
    } catch (e) {
      print("Konum alınırken hata: $e");
      // Hata durumunda kullanıcıya bilgi verebilirsiniz.
      _latitude = null;
      _longitude = null;
      notifyListeners();
    }
  }
}

Future<void> requestBackgroundLocationPermission() async {
  var status = await Permission.locationAlways.status;
  if (!status.isGranted) {
    await Permission.locationAlways.request();
  }
}

