// lib/utils/earthquake_detector.dart
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

class EarthquakeDetector extends ChangeNotifier {
  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;
  bool _isListening = false;
  final double _accelerationThreshold = 18.0; // Adjust as needed
  final double _angularVelocityThreshold = 2.5; // Adjust as needed
  final Duration _durationThreshold = const Duration(milliseconds: 600); // Adjust as needed
  DateTime? _shakeStartTime;

  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _gyroscopeSubscription;

  // Callback for when an earthquake is detected
  VoidCallback? onEarthquakeDetected;

  EarthquakeDetector({this.onEarthquakeDetected});

  bool get isListening => _isListening;

  void startListening() {
    if (_isListening) return;

    _isListening = true;
    _accelerometerSubscription = userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      _accelerometerValues = <double>[event.x, event.y, event.z];
      _checkShake();
    });
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      _gyroscopeValues = <double>[event.x, event.y, event.z];
      _checkShake();
    });
    notifyListeners();
  }

  void stopListening() {
    if (!_isListening) return;

    _isListening = false;
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _shakeStartTime = null;
    notifyListeners();
  }

  void _checkShake() {
    bool currentAccelerometerExceeded = _accelerometerValues != null &&
        (_accelerometerValues![0].abs() > _accelerationThreshold ||
            _accelerometerValues![1].abs() > _accelerationThreshold ||
            _accelerometerValues![2].abs() > _accelerationThreshold);

    bool currentGyroscopeExceeded = _gyroscopeValues != null &&
        (_gyroscopeValues![0].abs() > _angularVelocityThreshold ||
            _gyroscopeValues![1].abs() > _angularVelocityThreshold ||
            _gyroscopeValues![2].abs() > _angularVelocityThreshold);

    if (currentAccelerometerExceeded || currentGyroscopeExceeded) {
      if (_shakeStartTime == null) {
        _shakeStartTime = DateTime.now();
      } else if (DateTime.now().difference(_shakeStartTime!) > _durationThreshold) {
        print("Earthquake detected!");
        onEarthquakeDetected?.call();
        _shakeStartTime = null; // Reset to detect next shake
        stopListening(); // Stop listening after detection to prevent multiple triggers
      }
    } else {
      _shakeStartTime = null;
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    super.dispose();
  }
}