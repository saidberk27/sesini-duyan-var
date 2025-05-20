import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as location_service;
import 'package:sesini_duyan_var/models/chat_message.dart';

class BluetoothService extends ChangeNotifier {
  final Nearby _nearby = Nearby();
  final location_service.Location _location = location_service.Location();
  final String _serviceId = "com.example.nearbychat";
  final Strategy _strategy = Strategy.P2P_CLUSTER;
  final Map<String, String> _deviceNames = {};

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  // Cihaz adı yönetimi
  void setDeviceName(String endpointId, String name) {
    _deviceNames[endpointId] = name;
  }

  String? getDeviceName(String endpointId) {
    return _deviceNames[endpointId];
  }

  Future<bool> checkAndRequestPermissions() async {
    try {
      List<Permission> permissions = [
        Permission.bluetooth,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
        Permission.locationAlways,
        Permission.locationWhenInUse,
        Permission.microphone,
        Permission.nearbyWifiDevices,
      ];

      for (var permission in permissions) {
        if (await permission.status != PermissionStatus.granted) {
          final status = await permission.request();
          if (status != PermissionStatus.granted) {
            print('${permission.toString()} is not granted: $status');
          }
        }
      }

      bool locationServiceEnabled = await _location.serviceEnabled();
      if (!locationServiceEnabled) {
        locationServiceEnabled = await _location.requestService();
        if (!locationServiceEnabled) {
          throw Exception('Location services are disabled');
        }
      }

      bool allGranted = true;
      List<String> deniedPermissions = [];

      for (var permission in permissions) {
        final status = await permission.status;
        if (status != PermissionStatus.granted) {
          allGranted = false;
          deniedPermissions.add(permission.toString());
        }
      }

      if (!allGranted) {
        throw Exception(
          'Please grant all required permissions from settings: ${deniedPermissions.join(", ")}',
        );
      }

      return true;
    } catch (e) {
      print('Permission check failed: $e');
      rethrow;
    }
  }

  Future<bool> startAdvertising({
    required String userName,
    required Function(String, ConnectionInfo) onConnectionInitiated,
    required Function(String, Status) onConnectionResult,
    required Function(String) onDisconnected,
  }) async {
    try {
      await checkAndRequestPermissions();

      return await _nearby.startAdvertising(
        userName,
        _strategy,
        onConnectionInitiated: (String id, ConnectionInfo info) {
          _deviceNames[id] = info.endpointName;
          onConnectionInitiated(id, info);
        },
        onConnectionResult: onConnectionResult,
        onDisconnected: onDisconnected,
        serviceId: _serviceId,
      );
    } catch (e) {
      print('Start advertising failed: $e');
      rethrow;
    }
  }

  Future<bool> startDiscovery({
    required String userName,
    required Function(String, String, String) onEndpointFound,
    required Function(String?) onEndpointLost,
  }) async {
    try {
      await checkAndRequestPermissions();

      return await _nearby.startDiscovery(
        userName,
        _strategy,
        onEndpointFound: (
          String endpointId,
          String endpointName,
          String serviceId,
        ) {
          _deviceNames[endpointId] = endpointName;
          onEndpointFound(endpointId, endpointName, serviceId);
        },
        onEndpointLost: onEndpointLost,
        serviceId: _serviceId,
      );
    } catch (e) {
      print('Start discovery failed: $e');
      rethrow;
    }
  }

  Future<void> stopAdvertising() async {
    try {
      await _nearby.stopAdvertising();
    } catch (e) {
      print('Stop advertising failed: $e');
      rethrow;
    }
  }

  Future<void> stopDiscovery() async {
    try {
      await _nearby.stopDiscovery();
    } catch (e) {
      print('Stop discovery failed: $e');
      rethrow;
    }
  }

  Future<void> requestConnection({
    required String userName,
    required String endpointId,
    required Function(String, ConnectionInfo) onConnectionInitiated,
    required Function(String, Status) onConnectionResult,
    required Function(String) onDisconnected,
  }) async {
    try {
      await checkAndRequestPermissions();

      await _nearby.requestConnection(
        userName,
        endpointId,
        onConnectionInitiated: (String id, ConnectionInfo info) {
          _deviceNames[id] = info.endpointName;
          onConnectionInitiated(id, info);
        },
        onConnectionResult: onConnectionResult,
        onDisconnected: onDisconnected,
      );
    } catch (e) {
      print('Request connection failed: $e');
      rethrow;
    }
  }

  Future<void> acceptConnection({
    required String endpointId,
    required Function(String, Payload) onPayLoadReceived,
    required Function(String, PayloadTransferUpdate) onPayloadTransferUpdate,
  }) async {
    try {
      await checkAndRequestPermissions();

      await _nearby.acceptConnection(
        endpointId,
        onPayLoadRecieved: onPayLoadReceived,
        onPayloadTransferUpdate: onPayloadTransferUpdate,
      );
    } catch (e) {
      print('Accept connection failed: $e');
      rethrow;
    }
  }

  Future<void> rejectConnection(String endpointId) async {
    try {
      await _nearby.rejectConnection(endpointId);
    } catch (e) {
      print('Reject connection failed: $e');
      rethrow;
    }
  }

  Future<void> disconnectFromEndpoint(String endpointId) async {
    try {
      await _nearby.disconnectFromEndpoint(endpointId);
      _deviceNames.remove(endpointId);
    } catch (e) {
      print('Disconnect from endpoint failed: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(String endpointId, String message) async {
    try {
      final bytes = Uint8List.fromList(message.codeUnits);
      await _nearby.sendBytesPayload(endpointId, bytes);
    } catch (e) {
      print('Send message failed: $e');
      rethrow;
    }
  }

  void stopAllEndpoints() {
    try {
      _nearby.stopAllEndpoints();
      _deviceNames.clear();
    } catch (e) {
      print('Stop all endpoints failed: $e');
      rethrow;
    }
  }
}
