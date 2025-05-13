import 'package:cloud_firestore/cloud_firestore.dart';

class LocationDataModel {
  final double latitude;
  final double longitude;
  final Timestamp timestamp;
  final String? userId;

  LocationDataModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude, // Alan adını güncelledik
      'longitude': longitude, // Alan adını güncelledik
      'timestamp': timestamp,
      'userId': userId,
    };
  }

  factory LocationDataModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return LocationDataModel(
      latitude: data?['latitude'] ?? 0.0, // Alan adını güncelledik
      longitude: data?['longitude'] ?? 0.0, // Alan adını güncelledik
      timestamp: data?['timestamp'] ?? Timestamp.now(),
      userId: data?['userId'],
    );
  }
}
