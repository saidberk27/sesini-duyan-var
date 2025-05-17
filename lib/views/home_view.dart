import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sesini_duyan_var/viewmodels/send_location_model.dart';
import 'package:sesini_duyan_var/theme/app_theme.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;
  bool _isListening = false;
  final double _accelerationThreshold = 18.0; // Ayarlanabilir ivme eşiği (m/s^2)
  final double _angularVelocityThreshold = 2.5; // Ayarlanabilir açısal hız eşiği (rad/s)
  final Duration _durationThreshold = const Duration(milliseconds: 600); // Ayarlanabilir süre eşiği
  DateTime? _shakeStartTime;
  bool _accelerometerThresholdExceeded = false;
  bool _gyroscopeThresholdExceeded = false;

  @override
  void initState() {
    super.initState();
    _startListening(); // Sayfa ilk açıldığında dinlemeyi başlat
  }

  @override
  void dispose() {
    _stopListening(); // Sayfa kapatıldığında dinlemeyi durdur
    super.dispose();
  }

  void _startListening() {
    setState(() {
      _isListening = true;
    });
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
        _checkShake();
      });
    });
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
        _checkShake();
      });
    });
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    // Gerekirse event dinlemelerini iptal edebilirsiniz.
    // Ancak listen metodu doğrudan iptal mekanizması sunmaz.
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
        _navigateToAlert();
        _shakeStartTime = null; // Reset
      }
    } else {
      _shakeStartTime = null; // Sarsıntı durdu
    }
  }

  void _navigateToAlert() {
    if (mounted) {
      Navigator.pushNamed(context, '/alert');
      _stopListening(); // Uyarı sayfasına giderken dinlemeyi durdur
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationViewModel = Provider.of<SendLocationViewModel>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Acil Durum (Logo) Kartı
          InkWell(
            onDoubleTap: () {
              print(
                "Logo'ya çift tıklandı, konum alınıyor ve AlertPage'e gidilecek...",
              );
              locationViewModel
                  .getCurrentLocation()
                  .then((_) {
                if (locationViewModel.latitude != null &&
                    locationViewModel.longitude != null) {
                  Navigator.pushNamed(context, '/alert');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Konum bilgisi alınamadı. Lütfen konum servislerini ve izinleri kontrol edin.',
                      ),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              })
                  .catchError((error) {
                print("Konum alınırken hata (HomePage): $error");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Konum alınırken bir hata oluştu: $error',
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              });
            },
            child: Card(
              elevation: 2,
              color: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 16), // Alt boşluk azaltıldı
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo0.png',
                      height: 150, // Boyut biraz küçültüldü
                      width: 150, // Boyut biraz küçültüldü
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.grey,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Acil Durum İçin Çift Tıkla",
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- YENİ BLUETOOTH MESAJLAŞMA KARTI (Logo formatında) ---
          InkWell(
            onTap: () {
              // Çift tıklama yerine tek tıklama
              Navigator.pushNamed(context, '/bluetooth');
            },
            borderRadius: BorderRadius.circular(
              12,
            ), // InkWell için de border radius
            child: Card(
              elevation: 2,
              color:
              theme.scaffoldBackgroundColor, // Logo kartıyla aynı arka plan
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(
                bottom: 24,
              ), // Diğer kartlarla aynı boşluk
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ), // Logo kartına benzer padding
                child: Column(
                  // İçerik dikeyde ortalansın
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bluetooth_searching_rounded,
                      size: 60, // İkon boyutu
                      color: AppTheme.primaryColor, // Temadan renk
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bluetooth Mesajlaşma',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- BLUETOOTH MESAJLAŞMA KARTI BİTİŞ ---
          HomePageCard(
            icon: Icons.person_outline_rounded,
            title: 'Kullanıcı Profilim',
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.secondaryColor.shade100,
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          const SizedBox(height: 16),
          // Diğer HomePageCard'lar aynı kalır
          HomePageCard(
            icon: Icons.settings_outlined,
            title: 'Uygulama Ayarları',
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.secondaryColor.shade100,
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const SizedBox(height: 16),
          HomePageCard(
            icon: Icons.info_outline_rounded,
            title: 'Proje Hakkında',
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.secondaryColor.shade100,
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          const SizedBox(height: 16),
          HomePageCard(
            icon: Icons.privacy_tip_outlined,
            title: 'KVKK & Gizlilik',
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.secondaryColor.shade100,
            onTap: () {
              Navigator.pushNamed(context, '/kvkk');
            },
          ),
          const SizedBox(height: 16),
          HomePageCard(
            icon: Icons.logout_rounded,
            title: 'Çıkış Yap',
            color: Colors.red.shade700,
            backgroundColor: Colors.red.shade50,
            onTap: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
              print("Çıkış yap butonuna basıldı.");
            },
          ),
        ],
      ),
    );
  }
}

class HomePageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const HomePageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.backgroundColor,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: backgroundColor,
                radius: 26,
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.primaryColorDark.withOpacity(0.7),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}