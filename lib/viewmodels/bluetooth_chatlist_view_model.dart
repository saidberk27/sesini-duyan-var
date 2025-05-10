import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
// BluetoothService'i import etmemiz gerekiyor. Dosya yolunuzu kontrol edin.
// Eğer services klasörü lib altındaysa ve viewmodels de lib altındaysa:
import '../services/bluetooth_service.dart';

class BluetoothListViewModel extends ChangeNotifier {
  final BluetoothService _bluetoothService = BluetoothService();

  List<BluetoothDiscoveryResult> _discoveredDevices = [];
  List<BluetoothDiscoveryResult> get discoveredDevices => _discoveredDevices;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDiscovering = false;
  bool get isDiscovering => _isDiscovering;

  bool _permissionsGranted = false;
  bool get permissionsGranted => _permissionsGranted;

  StreamSubscription? _discoveryStreamSubscription;

  BluetoothListViewModel() {
    // ViewModel oluşturulduğunda Bluetooth'u etkinleştirme isteği
    _bluetoothService.requestEnableBluetooth().then((enabled) {
      if (!enabled) {
        _errorMessage = "Listeleme için Bluetooth etkinleştirilmedi.";
        notifyListeners();
      } else {
        // Bluetooth açıldıktan sonra izinleri kontrol et/iste (isteğe bağlı ilk yükleme)
        // Pasif tarama veya eşlenmiş cihazları listeleme burada yapılabilir.
        // Şimdilik sadece tarama butonuyla aktif tarama yapacağız.
      }
    });

    // Keşfedilen cihazlar stream'ini dinle
    _discoveryStreamSubscription = _bluetoothService.discoveryResultStream.listen(
      (results) {
        _discoveredDevices = results;
        if (_discoveredDevices.isEmpty && _isDiscovering) {
          // Tarama devam ediyor ama henüz cihaz bulunamadıysa bir mesaj gösterilebilir.
          // _errorMessage = "Cihaz aranıyor...";
        } else if (_discoveredDevices.isEmpty && !_isDiscovering) {
          // Tarama bitti ve cihaz bulunamadı.
          // _errorMessage = "Yakınlarda cihaz bulunamadı.";
        }
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = "Cihaz arama hatası: $error";
        _isDiscovering = false;
        notifyListeners();
      },
    );
  }

  Future<bool> checkAndRequestPermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect, // Bağlantı için de gerekebilir
          Permission.locationWhenInUse,
        ].request();

    _permissionsGranted = statuses.values.every((status) => status.isGranted);

    if (!_permissionsGranted) {
      _errorMessage = "Bluetooth işlemleri için gerekli izinler verilmedi.";
      statuses.forEach((permission, status) {
        if (!status.isGranted) {
          print("${permission.toString()} izni verilmedi. Durum: $status");
        }
      });
    } else {
      _errorMessage = null;
    }
    notifyListeners();
    return _permissionsGranted;
  }

  Future<void> startDiscovery() async {
    _errorMessage = null;
    _isDiscovering = true;
    _discoveredDevices = []; // Yeni tarama öncesi listeyi temizle
    notifyListeners();

    bool permissionsOk = await checkAndRequestPermissions();
    if (!permissionsOk) {
      _isDiscovering = false;
      notifyListeners();
      return;
    }

    bool? btEnabled = await FlutterBluetoothSerial.instance.isEnabled;
    if (btEnabled != true) {
      _errorMessage = "Lütfen Bluetooth'u açın.";
      _isDiscovering = false;
      notifyListeners();
      bool requested = await _bluetoothService.requestEnableBluetooth();
      if (!requested) {
        _isDiscovering = false;
        notifyListeners();
        return;
      }
    }
    // İzinler ve Bluetooth durumu tamam, taramayı başlat
    _bluetoothService.startDiscovery();
  }

  void stopDiscovery() {
    if (_isDiscovering) {
      _isDiscovering = false;
      _bluetoothService.stopDiscovery();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    print("BluetoothListViewModel disposing...");
    stopDiscovery();
    _discoveryStreamSubscription?.cancel();
    // _bluetoothService.dispose(); // BluetoothService, ChatViewModel tarafından da kullanılabilir,
    // bu yüzden burada dispose etmeyebiliriz veya referans sayımı yapılabilir.
    // Şimdilik ChatViewModel'in dispose etmesine bırakalım.
    super.dispose();
  }
}
