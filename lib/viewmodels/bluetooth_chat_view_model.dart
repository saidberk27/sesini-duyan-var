// lib/viewmodels/chat_view_model.dart
import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import '../models/chat_message.dart';

class ChatViewModel extends ChangeNotifier {
  final BluetoothService bluetoothService;
  final String deviceId;
  List<ChatMessage> _messages = [];
  String? _error;
  String? _deviceName;
  bool _isConnected = true;

  ChatViewModel({required this.bluetoothService, required this.deviceId}) {
    _initializeDevice();
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  String? get error => _error;
  String get deviceName => _deviceName ?? 'Unknown Device';
  bool get isConnected => _isConnected;

  void _initializeDevice() {
    try {
      _deviceName = bluetoothService.getDeviceName(deviceId);
      notifyListeners();
    } catch (e) {
      _error = "Failed to get device name: $e";
      notifyListeners();
    }
  }

  void updateDeviceName(String name) {
    _deviceName = name;
    bluetoothService.setDeviceName(deviceId, name);
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    try {
      await bluetoothService.sendMessage(deviceId, message);
      _addMessage(message, true);
      _error = null;
    } catch (e) {
      _error = "Failed to send message: $e";
      notifyListeners();
      print("Error sending message: $e");
    }
  }

  void _addMessage(String text, bool isMe) {
    _messages.insert(
      0,
      ChatMessage(text: text, isMe: isMe, time: DateTime.now()),
    );
    notifyListeners();
  }

  void receiveMessage(String message) {
    _addMessage(message, false);
  }

  void setConnectionStatus(bool connected) {
    _isConnected = connected;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> disconnect() async {
    try {
      await bluetoothService.disconnectFromEndpoint(deviceId);
      setConnectionStatus(false);
    } catch (e) {
      _error = "Failed to disconnect: $e";
      notifyListeners();
    }
  }

  @override
  void dispose() {
    try {
      bluetoothService.disconnectFromEndpoint(deviceId);
    } catch (e) {
      print("Error during dispose: $e");
    }
    super.dispose();
  }
}
