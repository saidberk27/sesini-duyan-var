import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/bluetooth_service.dart';

class BluetoothChatViewModel extends ChangeNotifier {
  final BluetoothService _bluetoothService = BluetoothService();

  List<BluetoothDiscoveryResult> _discoveredDevices =
      []; // Bu ViewModel'de artık kullanılmayacak
  List<BluetoothDiscoveryResult> get discoveredDevices => _discoveredDevices;

  BluetoothDevice? _selectedDevice; // Bu, initialDevice'dan gelecek
  BluetoothDevice? get selectedDevice => _connectedDevice ?? _selectedDevice;
  BluetoothDevice? get _connectedDevice => _bluetoothService.connectedDevice;

  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  BluetoothConnectionState get connectionState => _connectionState;

  final List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // isDiscovering ve permissionsGranted bu ViewModel'den kaldırıldı, ListViewModel'de olacak.
  // bool _isDiscovering = false;
  // bool get isDiscovering => _isDiscovering;
  // bool _permissionsGranted = false;
  // bool get permissionsGranted => _permissionsGranted;

  StreamSubscription? _connectionStateSubscription;
  StreamSubscription? _receivedMessagesSubscription;
  // _discoveryStreamSubscription da kaldırıldı.

  BluetoothChatViewModel({BluetoothDevice? initialDevice}) {
    _selectedDevice =
        initialDevice; // Başlangıçta gösterilecek/bağlanılacak cihazı ayarla

    _connectionStateSubscription = _bluetoothService.connectionStateStream.listen((
      state,
    ) {
      _connectionState = state;
      if (state == BluetoothConnectionState.error) {
        _errorMessage = "Bağlantı hatası oluştu.";
      } else if (state == BluetoothConnectionState.disconnected) {
        _addMessage("Bağlantı kesildi.", false, isSystemMessage: true);
        // _selectedDevice null yapılmamalı, kullanıcı tekrar bağlanmayı deneyebilir.
      } else if (state == BluetoothConnectionState.connected &&
          _bluetoothService.connectedDevice != null) {
        _addMessage(
          "${_bluetoothService.connectedDevice!.name ?? _bluetoothService.connectedDevice!.address} cihazına bağlandı.",
          false,
          isSystemMessage: true,
        );
        _errorMessage = null; // Başarılı bağlantıda hata mesajını temizle
      }
      notifyListeners();
    });

    _receivedMessagesSubscription = _bluetoothService.receivedMessagesStream
        .listen((message) {
          _addMessage(message, false);
        });

    // _initialize metodu kaldırıldı, otomatik bağlantı olmayacak.
    // Bluetooth etkinleştirme isteği de burada olmayacak,
    // bu sayfa açıldığında Bluetooth'un zaten açık olması beklenir
    // veya kullanıcıya bir uyarı gösterilebilir.
    // Şimdilik, BluetoothService'in bunu bir şekilde hallettiğini varsayalım
    // ya da bu sayfaya gelmeden önce Bluetooth'un açık olduğundan emin olunmalı.
    checkBluetoothEnabled(); // Bluetooth durumunu kontrol et
  }

  Future<void> checkBluetoothEnabled() async {
    bool? btEnabled = await FlutterBluetoothSerial.instance.isEnabled;
    if (btEnabled != true) {
      _errorMessage = "Sohbet için Bluetooth'u açın.";
      notifyListeners();
      // Kullanıcıyı Bluetooth'u açmaya yönlendirme UI'da veya burada yapılabilir.
      // await _bluetoothService.requestEnableBluetooth();
    }
  }

  void _addMessage(String text, bool isMe, {bool isSystemMessage = false}) {
    _messages.add({
      'text': text,
      'isMe': isMe,
      'isSystemMessage': isSystemMessage,
    });
    notifyListeners();
  }

  // İzin kontrolü burada da kalabilir, özellikle bağlanma öncesi.
  Future<bool> checkAndRequestConnectPermission() async {
    PermissionStatus connectStatus =
        await Permission.bluetoothConnect.request();
    // İsteğe bağlı: location izni de bazen bağlantı için dolaylı yoldan gerekebilir.
    // PermissionStatus locationStatus = await Permission.locationWhenInUse.request();

    if (!connectStatus.isGranted) {
      _errorMessage = "Cihaza bağlanmak için Bluetooth Connect izni gerekli.";
      notifyListeners();
      return false;
    }
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  Future<void> attemptConnectToSelectedDevice() async {
    if (_selectedDevice == null) {
      _errorMessage = "Bağlanılacak bir cihaz seçilmedi.";
      notifyListeners();
      return;
    }
    if (_connectionState == BluetoothConnectionState.connected &&
        _connectedDevice?.address == _selectedDevice!.address) {
      _addMessage("Zaten bu cihaza bağlısınız.", false, isSystemMessage: true);
      return;
    }

    _errorMessage = null;
    // _connectionState = BluetoothConnectionState.connecting; // Bu BluetoothService içinde ayarlanıyor
    notifyListeners(); // UI'da "Bağlanılıyor..." göstermek için

    bool permissionsOk = await checkAndRequestConnectPermission();
    if (!permissionsOk) {
      return;
    }

    bool? btEnabled = await FlutterBluetoothSerial.instance.isEnabled;
    if (btEnabled != true) {
      _errorMessage = "Lütfen Bluetooth'u açın.";
      notifyListeners();
      bool requested = await _bluetoothService.requestEnableBluetooth();
      if (!requested) return;
    }

    await _bluetoothService.connectToDevice(_selectedDevice!);
  }

  Future<void> disconnect() async {
    await _bluetoothService.disconnect();
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    if (_connectionState == BluetoothConnectionState.connected) {
      await _bluetoothService.sendMessage(message);
      _addMessage(message, true);
    } else {
      _errorMessage = "Mesaj gönderilemedi: Bağlantı yok.";
      notifyListeners();
    }
  }

  @override
  void dispose() {
    print("BluetoothChatViewModel disposing...");
    // Bu ViewModel artık tarama yapmadığı için stopDiscovery'e gerek yok.
    // Bağlantıyı kesmek isteğe bağlı, sayfa kapanınca kesilsin mi?
    // Şimdilik kesmiyoruz, kullanıcı manuel kesebilir.
    // _bluetoothService.disconnect();
    _connectionStateSubscription?.cancel();
    _receivedMessagesSubscription?.cancel();
    _bluetoothService.dispose(); // BluetoothService'i burada dispose edelim.
    // Eğer birden fazla ViewModel paylaşıyorsa dikkatli olunmalı.
    // Bu örnekte her ChatPage kendi Service'ini oluşturuyor gibi varsayıyoruz.
    super.dispose();
  }
}
