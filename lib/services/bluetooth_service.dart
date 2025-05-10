import 'dart:async';
import 'dart:convert'; // utf8 için
import 'dart:typed_data'; // Uint8List için
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// Bluetooth bağlantı durumlarını temsil eden enum
enum BluetoothConnectionState { disconnected, connecting, connected, error }

class BluetoothService {
  // Singleton instance oluşturma (isteğe bağlı, Provider ile de yönetilebilir)
  // static final BluetoothService _instance = BluetoothService._internal();
  // factory BluetoothService() => _instance;
  // BluetoothService._internal();

  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection; // Aktif bağlantı
  BluetoothDevice? _connectedDevice; // Bağlı olan cihaz

  // Bağlantı durumu için StreamController
  final _connectionStateController =
      StreamController<BluetoothConnectionState>.broadcast();
  Stream<BluetoothConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  // Gelen mesajlar için StreamController
  final _receivedMessagesController = StreamController<String>.broadcast();
  Stream<String> get receivedMessagesStream =>
      _receivedMessagesController.stream;

  // Keşfedilen cihazlar için StreamController
  final _discoveryResultController =
      StreamController<List<BluetoothDiscoveryResult>>.broadcast();
  Stream<List<BluetoothDiscoveryResult>> get discoveryResultStream =>
      _discoveryResultController.stream;

  List<BluetoothDiscoveryResult> _discoveryResults = [];
  StreamSubscription? _discoveryStreamSubscription;

  BluetoothService() {
    // Bluetooth durumu değişikliklerini dinle
    _bluetooth.state.then((state) {
      print("Bluetooth durumu: $state");
      if (state == BluetoothState.STATE_OFF) {
        // Bluetooth kapalıysa kullanıcıyı uyarabilir veya açmasını isteyebilirsiniz.
      }
    });
  }

  // Bluetooth'u açma isteği (kullanıcı onayı gerektirir)
  Future<bool> requestEnableBluetooth() async {
    bool? enabled = await _bluetooth.requestEnable();
    return enabled ?? false;
  }

  // Cihaz keşfini başlat
  void startDiscovery() {
    _discoveryResults = []; // Eski sonuçları temizle
    _discoveryResultController.add(_discoveryResults); // UI'ı güncelle

    _discoveryStreamSubscription = _bluetooth.startDiscovery().listen((result) {
      // Aynı cihazın birden fazla kez eklenmesini engelle
      final existingIndex = _discoveryResults.indexWhere(
        (element) => element.device.address == result.device.address,
      );
      if (existingIndex >= 0) {
        // _discoveryResults[existingIndex] = result; // Güncellemek isterseniz
      } else {
        if (result.device.name != null && result.device.name!.isNotEmpty) {
          _discoveryResults.add(result);
        }
      }
      _discoveryResultController.add(
        List.from(_discoveryResults),
      ); // Yeni listeyi yayınla
    });

    _discoveryStreamSubscription?.onDone(() {
      print("Cihaz keşfi tamamlandı.");
      // Keşif bittiğinde bir işlem yapılabilir.
    });
    _discoveryStreamSubscription?.onError((error) {
      print("Cihaz keşfi hatası: $error");
      _discoveryResultController.addError(error);
    });
  }

  // Cihaz keşfini durdur
  void stopDiscovery() {
    _discoveryStreamSubscription?.cancel();
  }

  // Bir cihaza bağlan
  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_connection != null && _connection!.isConnected) {
      print("Zaten bir cihaza bağlı.");
      if (_connectedDevice?.address == device.address)
        return; // Aynı cihaza tekrar bağlanma
      await disconnect(); // Önceki bağlantıyı kes
    }

    _connectionStateController.add(BluetoothConnectionState.connecting);
    print("Cihaza bağlanılıyor: ${device.name} (${device.address})");

    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _connectedDevice = device;
      _connectionStateController.add(BluetoothConnectionState.connected);
      print("Bağlantı başarılı: ${device.name}");

      // Gelen verileri dinle
      _connection?.input
          ?.listen((Uint8List data) {
            String message = utf8.decode(data); // Gelen veriyi String'e çevir
            _receivedMessagesController.add(message);
            print("Gelen mesaj: $message");
          })
          .onDone(() {
            print("Bağlantı sonlandı (onDone).");
            _connectionStateController.add(
              BluetoothConnectionState.disconnected,
            );
            _connectedDevice = null;
          });
    } catch (e) {
      print("Bağlantı hatası: $e");
      _connectionStateController.add(BluetoothConnectionState.error);
      _connectedDevice = null;
      // Tekrar bağlanmayı deneyebilir veya kullanıcıya hata gösterebilirsiniz.
    }
  }

  // Mesaj gönder
  Future<void> sendMessage(String message) async {
    if (_connection != null && _connection!.isConnected) {
      try {
        // Mesajı Uint8List'e çevirip gönder
        _connection!.output.add(Uint8List.fromList(utf8.encode(message)));
        await _connection!
            .output
            .allSent; // Tüm verinin gönderildiğinden emin ol
        print("Mesaj gönderildi: $message");
      } catch (e) {
        print("Mesaj gönderme hatası: $e");
        _connectionStateController.add(BluetoothConnectionState.error);
        // Hata durumunda bağlantıyı sonlandırmayı veya yeniden kurmayı düşünebilirsiniz.
      }
    } else {
      print("Mesaj gönderilemedi: Bağlantı yok.");
      // Kullanıcıya bağlantı olmadığını bildirin.
    }
  }

  // Bağlantıyı kes
  Future<void> disconnect() async {
    if (_connection != null) {
      await _connection?.close(); // Bağlantıyı kapat
      _connection = null;
      _connectedDevice = null;
      _connectionStateController.add(BluetoothConnectionState.disconnected);
      print("Bağlantı kesildi.");
    }
  }

  // Servis sonlandırılırken stream'leri kapat
  void dispose() {
    stopDiscovery();
    disconnect();
    _connectionStateController.close();
    _receivedMessagesController.close();
    _discoveryResultController.close();
  }

  // Bağlı cihazı döndürür
  BluetoothDevice? get connectedDevice => _connectedDevice;
}
