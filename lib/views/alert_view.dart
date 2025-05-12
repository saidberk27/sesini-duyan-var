import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sesini_duyan_var/viewmodels/send_location_model.dart';
import 'package:sesini_duyan_var/services/firestore_service.dart';
import 'package:sesini_duyan_var/models/location_data_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package

class AlertPage extends StatefulWidget {
  const AlertPage({Key? key}) : super(key: key);

  @override
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final _firestoreService = FirestoreService();
  String _locationName = 'Konum aranıyor...'; // Add location name variable

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _uploadLocationToFirestore(context);
    _getLocationName(context); // Get location name
  }

  Future<void> _uploadLocationToFirestore(BuildContext context) async {
    final locationViewModel =
    Provider.of<SendLocationViewModel>(context, listen: false);

    if (locationViewModel.latitude != null &&
        locationViewModel.longitude != null) {
      final locationData = LocationDataModel(
        latitude: locationViewModel.latitude!,
        longitude: locationViewModel.longitude!,
        timestamp: Timestamp.now(),
      );

      try {
        await _firestoreService.recordLocationDataModel(locationData);
        print('Konum verisi Firestore\'a başarıyla kaydedildi.');
      } catch (e) {
        print('Konum verisi Firestore\'a kaydedilirken hata: $e');
      }
    } else {
      print('Konum verisi alınamadı, Firestore\'a kaydedilmedi.');
    }
  }

  // Function to get location name from coordinates
  Future<void> _getLocationName(BuildContext context) async {
    final locationViewModel =
    Provider.of<SendLocationViewModel>(context, listen: false);
    if (locationViewModel.latitude != null &&
        locationViewModel.longitude != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            locationViewModel.latitude!, locationViewModel.longitude!);

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          setState(() {
            _locationName =
            '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
          });
        } else {
          setState(() {
            _locationName = 'Konum Bulunamadı';
          });
        }
      } catch (e) {
        print('Konum adı alınırken hata: $e');
        setState(() {
          _locationName = 'Konum Bulunamadı';
        });
      }
    } else {
      setState(() {
        _locationName = 'Konum Bilgisi Yok';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final primaryColor = theme.primaryColor;
    final Color backgroundColor =
    const Color.fromRGBO(150, 170, 180, 1); // Daha koyu ve pastel mavi/gri (96AABB)
    final locationViewModel = Provider.of<SendLocationViewModel>(context);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: FadeTransition(
        opacity: _animation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 80,
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),
                Text(
                  'DEPREM!',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 60,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Tahmini Şiddet: 6.4',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tahmini Merkez Üssü Uzaklığı: 4.7 km',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Konumunuz: $_locationName', // Display the location name with "Konumunuz:"
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Text(
                  'Verileriniz Merkeze Gönderiliyor...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Panik yapmadan güvenli bir alana geçin.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

