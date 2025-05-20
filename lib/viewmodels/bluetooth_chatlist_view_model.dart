import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import '../services/bluetooth_service.dart';
import '../models/connected_device.dart';
import '../models/chat_message.dart';

class ChatListViewModel extends ChangeNotifier {
  final BluetoothService _bluetoothService;
  bool _isAdvertising = false;
  bool _isDiscovering = false;
  List<ConnectedDevice> _connectedDevices = [];
  String? _selectedDeviceId;
  String? _error;
  Map<String, List<ChatMessage>> _messages = {};

  ChatListViewModel(this._bluetoothService);

  // Getters
  bool get isAdvertising => _isAdvertising;
  bool get isDiscovering => _isDiscovering;
  List<ConnectedDevice> get connectedDevices => _connectedDevices;
  String? get selectedDeviceId => _selectedDeviceId;
  String? get error => _error;
  Map<String, List<ChatMessage>> get messages => _messages;
  List<ChatMessage> getMessagesForDevice(String deviceId) =>
      _messages[deviceId] ?? [];

  // Initialize
  Future<void> initialize() async {
    try {
      await _bluetoothService.checkAndRequestPermissions();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Permission Error: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // Advertising
  Future<void> toggleAdvertising(String userName) async {
    try {
      if (_isAdvertising) {
        await _bluetoothService.stopAdvertising();
        _isAdvertising = false;
      } else {
        // İzinleri kontrol et
        await _bluetoothService.checkAndRequestPermissions();

        _isAdvertising = await _bluetoothService.startAdvertising(
          userName: userName,
          onConnectionInitiated: _handleConnectionInitiated,
          onConnectionResult: _handleConnectionResult,
          onDisconnected: _handleDisconnected,
        );
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isAdvertising = false;
      // Kullanıcıya izin hatası hakkında bilgi ver
      if (e.toString().contains('permissions')) {
        _error = 'Please grant all required permissions from settings';
      }
    }
    notifyListeners();
  }

  // Discovery
  Future<void> toggleDiscovery(String userName) async {
    try {
      if (_isDiscovering) {
        await _bluetoothService.stopDiscovery();
        _isDiscovering = false;
      } else {
        _isDiscovering = await _bluetoothService.startDiscovery(
          userName: userName,
          onEndpointFound: _handleEndpointFound,
          onEndpointLost: _handleEndpointLost,
        );
      }
      _error = null;
    } catch (e) {
      _error = 'Discovery Error: ${e.toString()}';
      _isDiscovering = false;
    }
    notifyListeners();
  }

  // Connection Handling Methods
  void _handleConnectionInitiated(String id, ConnectionInfo info) async {
    try {
      await _bluetoothService.acceptConnection(
        endpointId: id,
        onPayLoadReceived: (endpointId, payload) {
          if (payload.type == PayloadType.BYTES) {
            String message = String.fromCharCodes(payload.bytes!);
            _addMessage(endpointId, message, false);
          }
        },
        onPayloadTransferUpdate: (endpointId, update) {
          // Transfer durumu güncellemelerini işle
          if (update.status == PayloadStatus.FAILURE) {
            _error = 'Message transfer failed';
            notifyListeners();
          }
        },
      );
    } catch (e) {
      _error = 'Connection acceptance failed: ${e.toString()}';
      notifyListeners();
    }
  }

  void _handleConnectionResult(String id, Status status) {
    if (status == Status.CONNECTED) {
      final newDevice = ConnectedDevice(id: id, name: 'Device-$id');

      if (!_connectedDevices.any((device) => device.id == id)) {
        _connectedDevices.add(newDevice);
        _selectedDeviceId = id;
        if (!_messages.containsKey(id)) {
          _messages[id] = [];
        }
        notifyListeners();
      }
    }
  }

  void _handleDisconnected(String id) {
    _connectedDevices.removeWhere((device) => device.id == id);
    if (_selectedDeviceId == id) {
      _selectedDeviceId =
          _connectedDevices.isNotEmpty ? _connectedDevices.first.id : null;
    }
    notifyListeners();
  }

  void _handleEndpointFound(String id, String userName, String serviceId) {
    _requestConnection(id, userName);
  }

  void _handleEndpointLost(String? id) {
    if (id != null) {
      print('Endpoint lost: $id');
      _handleDisconnected(id);
    }
  }

  Future<void> _requestConnection(String id, String userName) async {
    try {
      await _bluetoothService.requestConnection(
        userName: userName,
        endpointId: id,
        onConnectionInitiated: _handleConnectionInitiated,
        onConnectionResult: _handleConnectionResult,
        onDisconnected: _handleDisconnected,
      );
    } catch (e) {
      _error = 'Connection request failed: ${e.toString()}';
      notifyListeners();
    }
  }

  // Message Handling
  void _addMessage(String deviceId, String text, bool isMe) {
    if (!_messages.containsKey(deviceId)) {
      _messages[deviceId] = [];
    }

    _messages[deviceId]!.add(
      ChatMessage(text: text, isMe: isMe, time: DateTime.now()),
    );
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    if (_selectedDeviceId == null || message.trim().isEmpty) return;

    try {
      await _bluetoothService.sendMessage(_selectedDeviceId!, message);
      _addMessage(_selectedDeviceId!, message, true);
    } catch (e) {
      _error = 'Message sending failed: ${e.toString()}';
      notifyListeners();
    }
  }

  // Device Selection
  void selectDevice(String deviceId) {
    _selectedDeviceId = deviceId;
    notifyListeners();
  }

  // Utility Methods
  bool isDeviceConnected(String deviceId) {
    return _connectedDevices.any((device) => device.id == deviceId);
  }

  ConnectedDevice? getDeviceById(String deviceId) {
    try {
      return _connectedDevices.firstWhere((device) => device.id == deviceId);
    } catch (e) {
      return null;
    }
  }

  void clearConnections() {
    _connectedDevices.clear();
    _selectedDeviceId = null;
    notifyListeners();
  }

  Future<void> disconnectDevice(String deviceId) async {
    try {
      await _bluetoothService.disconnectFromEndpoint(deviceId);
      _handleDisconnected(deviceId);
    } catch (e) {
      _error = 'Disconnection failed: ${e.toString()}';
      notifyListeners();
    }
  }

  // Error Handling
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Cleanup
  @override
  void dispose() {
    if (_isAdvertising) {
      _bluetoothService.stopAdvertising();
    }
    if (_isDiscovering) {
      _bluetoothService.stopDiscovery();
    }
    _bluetoothService.stopAllEndpoints();
    super.dispose();
  }
}
