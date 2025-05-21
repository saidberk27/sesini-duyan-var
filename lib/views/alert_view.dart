// lib/views/alert_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sesini_duyan_var/viewmodels/send_location_model.dart';
import 'package:geocoding/geocoding.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({Key? key}) : super(key: key);

  @override
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _locationName = 'Konum aranıyor...';
  String _uploadStatusMessage = 'Verileriniz Merkeze Gönderiliyor...';

  Future<bool> _onWillPop() async {
    Navigator.pop(context); // Mevcut AlertPage'i ekrandan kaldır
    return false; // Varsayılan geri gitme davranışını engelle
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerLocationOperations();
    });
  }

  Future<void> _triggerLocationOperations() async {
    final locationViewModel = Provider.of<SendLocationViewModel>(
      context,
      listen: false,
    );

    if (mounted) {
      print("AlertPage: ViewModel'in getKonum metodu tetikleniyor.");
      await locationViewModel.getKonum();
      if (mounted) {
        await _updateLocationNameFromViewModel();
      }
      if (mounted && locationViewModel.konumBilgisi.contains("başarıyla")) {
        setState(() {
          _uploadStatusMessage = "Konumunuz başarıyla merkeze iletildi.";
        });
      } else if (mounted &&
          (locationViewModel.konumBilgisi.contains("HATA") ||
              locationViewModel.konumBilgisi.contains("sorun") ||
              locationViewModel.konumBilgisi.contains("bulunamadı"))) {
        setState(() {
          _uploadStatusMessage =
          locationViewModel.konumBilgisi.isNotEmpty
              ? locationViewModel.konumBilgisi
              : "Konum gönderilirken bir sorun oluştu.";
        });
      }
    }
  }

  Future<void> _updateLocationNameFromViewModel() async {
    final locationViewModel = Provider.of<SendLocationViewModel>(
      context,
      listen: false,
    );
    if (locationViewModel.latitude != null &&
        locationViewModel.longitude != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          locationViewModel.latitude!,
          locationViewModel.longitude!,
        );
        if (mounted && placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          String street = place.street ?? '';
          String subLocality = place.subLocality ?? '';
          String locality = place.locality ?? '';
          String administrativeArea = place.administrativeArea ?? '';
          String country = place.country ?? '';

          List<String> addressParts =
          [
            street,
            subLocality,
            locality,
            administrativeArea,
            country,
          ].where((part) => part.isNotEmpty).toList();

          setState(() {
            _locationName = addressParts.join(', ');
            if (_locationName.isEmpty) {
              _locationName = 'Detaylı adres bilgisi bulunamadı.';
            }
          });
        } else if (mounted) {
          setState(() {
            _locationName = 'Adres bulunamadı';
          });
        }
      } catch (e) {
        print('Konum adı alınırken hata: $e');
        if (mounted) {
          setState(() {
            _locationName = 'Adres alınırken sorun oluştu';
          });
        }
      }
    } else if (mounted) {
      setState(() {
        _locationName = 'Konum bilgisi alınamıyor';
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
    final Color backgroundColor = const Color.fromRGBO(150, 170, 180, 1);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                  // Removed hardcoded intensity and epicenter distance
                  Text(
                    'Konumunuz: $_locationName',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Consumer<SendLocationViewModel>(
                    builder: (context, vm, child) {
                      String messageToShow = _uploadStatusMessage;
                      if (vm.isInitializing) {
                        messageToShow = "Başlatılıyor...";
                      } else if (vm.isFetchingLocation) {
                        messageToShow = "Konumunuz alınıyor...";
                      } else if (vm.isUploadingLocation) {
                        messageToShow = "Konumunuz merkeze gönderiliyor...";
                      } else if (vm.konumBilgisi.contains(
                        "başarıyla güncellendi",
                      ) ||
                          vm.konumBilgisi.contains("Firestore'a kaydedildi")) {
                        messageToShow = "Konumunuz başarıyla merkeze iletildi.";
                      } else if (vm.konumBilgisi.contains("HATA") ||
                          vm.konumBilgisi.contains("sorun") ||
                          vm.konumBilgisi.contains("bulunamadı") ||
                          vm.konumBilgisi.contains("yapılamıyor")) {
                        messageToShow = vm.konumBilgisi;
                      }
                      return Text(
                        messageToShow,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
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
      ),
    );
  }
}