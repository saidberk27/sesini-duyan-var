import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sesini_duyan_var/viewmodels/send_location_model.dart';
import 'package:sesini_duyan_var/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
