// lib/viewmodels/location_map_model.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart' as glocator; // İsim çakışmasını önlemek için alias
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong2/latlong.dart' as glocator; // flutter_map için LatLng2

// ViewModel sınıfı
class KonumHaritaViewModel extends ChangeNotifier {
  List<Marker> kullaniciKonumMarkerlari = []; // Markerlar List olarak tanımlandı

  // Geolocator'dan gelen mevcut konum için LatLng (geolocator'a ait)
  glocator.LatLng? kullaniciMevcutKonumGeolocator;

  final CollectionReference _kullanicilarRef =
  FirebaseFirestore.instance.collection('users');

  // flutter_map için LatLng2 olarak varsayılan Ankara konumu
  final LatLng ankaraLatLng2 = const LatLng(39.925533, 32.866287);

  // Zoom seviyesini bir sabit olarak tanımlayalım
  static const double haritaZoomSeviyesi = 9.0;

  bool _yukleniyor = false;
  bool get yukleniyor => _yukleniyor;

  String? _hataMesaji;
  String get hataMesaji => _hataMesaji ?? '';

  MapController? _mapController; // MapController eklendi (flutter_map için)
  MapController? get mapController => _mapController;

  KonumHaritaViewModel() {
    // ViewModel oluşturulduğunda otomatik olarak konum bulma işlemini başlatma
    // Bu, View'daki initState'te WidgetsBinding.instance.addPostFrameCallback ile daha güvenli tetiklenecek.
  }

  // MapController'ı set etmek için metod
  void setMapController(MapController controller) {
    _mapController = controller;
    // UI güncellemesi gerektirmediği için notifyListeners() çağrısına burada gerek yok.
  }

  // Kullanıcının mevcut konumunu bulma fonksiyonu
  Future<void> kullaniciMevcutKonumunuBul() async {
    _yukleniyor = true;
    _hataMesaji = null;
    notifyListeners(); // Yükleniyor durumunu UI'a bildir

    try {
      glocator.LocationPermission permission = await glocator.Geolocator.requestPermission();
      if (permission == glocator.LocationPermission.denied ||
          permission == glocator.LocationPermission.deniedForever) {
        _hataMesaji =
        'Konum izni verilmedi. Lütfen uygulama ayarlarından izin verin.';
        if (kDebugMode) {
          print("Konum izni verilmedi");
        }
        _yukleniyor = false;
        notifyListeners(); // Hata durumunda yükleniyor ve hata mesajını güncelle
        return;
      }

      glocator.Position position = await glocator.Geolocator.getCurrentPosition(
          desiredAccuracy: glocator.LocationAccuracy.high);
      kullaniciMevcutKonumGeolocator = glocator.LatLng(position.latitude, position.longitude);
      if (kDebugMode) {
        print("Mevcut konum bulundu: $kullaniciMevcutKonumGeolocator");
      }
    } catch (e) {
      _hataMesaji = 'Konum alınırken bir hata oluştu: $e';
      if (kDebugMode) {
        print("Konum alınırken hata: $e");
      }
    } finally {
      _yukleniyor = false;
      notifyListeners(); // İşlem bittiğinde yükleniyor durumunu güncelle
      // Konum bulunduktan sonra markerları getirmeyi çağır
      kullaniciKonumlariniGetirVeGoster();
    }
  }

  // Firestore'dan konum verilerini çekme ve haritada gösterme fonksiyonu
  Future<void> kullaniciKonumlariniGetirVeGoster() async {
    _yukleniyor = true;
    _hataMesaji = null;
    notifyListeners(); // Yükleniyor durumunu UI'a bildir

    try {
      // Tüm kullanıcıları çek
      QuerySnapshot kullaniciSnapshot = await _kullanicilarRef.get();

      if (kullaniciSnapshot.docs.isNotEmpty) {
        kullaniciKonumMarkerlari.clear(); // Önceki markerları temizle

        for (var kullaniciDoc in kullaniciSnapshot.docs) {
          GeoPoint? geoPoint =
          kullaniciDoc.get('location') as GeoPoint?; // "konum" yerine "location" kullanıldı.
          Timestamp? lastLocationUpdate =
          kullaniciDoc.get('lastLocationUpdate') as Timestamp?;
          String kullaniciAdi = kullaniciDoc.get('firstName') ?? 'Bilinmeyen Kullanıcı';
          String kullaniciSoyadi =
              kullaniciDoc.get('lastName') ?? '';
          String uzaklikBilgisi = '';
          String guncellemeZamaniBilgisi = '';

          if (geoPoint != null) {
            final LatLng konumLatLng2 = LatLng (geoPoint.latitude, geoPoint.longitude); // flutter_map için LatLng2 constructor

            if (kullaniciMevcutKonumGeolocator != null) {
              double uzaklikMetre = glocator.Geolocator.distanceBetween(
                kullaniciMevcutKonumGeolocator!.latitude,
                kullaniciMevcutKonumGeolocator!.longitude,
                geoPoint.latitude,
                geoPoint.longitude,
              );
              uzaklikBilgisi =
              ' (Yaklaşık ${uzaklikMetre.toStringAsFixed(0)} metre)';
            }
            if (lastLocationUpdate != null) {
              DateTime guncellemeZamaniUtc = lastLocationUpdate.toDate();
              DateTime guncellemeZamaniYerel = guncellemeZamaniUtc.toLocal();
              guncellemeZamaniBilgisi =
              'Güncellenme: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(guncellemeZamaniYerel)}';
            }

            // Marker'ın child'ı için bir IconButton oluştur ve tıklama bilgisini sakla
            // Bu bilgiyi marker'ın kendisiyle veya haricinde bir modelde saklayabilirsin.
            // Şimdilik Marker objesine geçici olarak ek bir veri eklemek yerine,
            // tıklanma anında SnackBar göstermek için gerekli bilgiyi burada oluşturalım.
            final String markerInfoSnippet = '$uzaklikBilgisi\n$guncellemeZamaniBilgisi';

            kullaniciKonumMarkerlari.add(
              Marker(
                point: konumLatLng2, // flutter_map için point kullanılıyor
                width: 80.0,
                height: 80.0,
                child: Builder( // Child'a context sağlamak için Builder kullandık
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.location_pin, color: Colors.red, size: 40,),
                        onPressed: () {
                          // Marker tıklandığında SnackBar ile bilgiyi gösterelim
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$kullaniciAdi $kullaniciSoyadi\n$markerInfoSnippet'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                      );
                    }
                ),
              ),
            );
          }
        }
        notifyListeners(); // Markerlar güncellendiğinde UI'ı bildir

        // Markerlar eklendikten sonra haritayı mevcut konuma odaklayabiliriz.
        if (_mapController != null && kullaniciMevcutKonumGeolocator != null) {
          _mapController!.move(
              LatLng(kullaniciMevcutKonumGeolocator!.latitude, kullaniciMevcutKonumGeolocator!.longitude),
              haritaZoomSeviyesi); // static olduğu için doğrudan erişim
        }
      }
    } catch (e) {
      _hataMesaji = 'Kullanıcı konumları alınırken bir hata oluştu: $e';
      if (kDebugMode) {
        print("Kullanıcı konumları alınırken hata: $e");
      }
    } finally {
      _yukleniyor = false; // Hata durumunda da _yukleniyor'u false yapın
      notifyListeners(); // En sonunda bildirim gönder
    }
  }
}