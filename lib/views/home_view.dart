import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sesini_duyan_var/viewmodels/send_location_model.dart'; // SendLocationViewModel'ı import edin
import 'package:sesini_duyan_var/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationViewModel = Provider.of<SendLocationViewModel>(context,
        listen: false); // ViewModel'a erişim

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        backgroundColor: theme.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InkWell(
            onDoubleTap: () {
              // Logo'ya çift tıklandığında yapılacak işlemler
              locationViewModel.getCurrentLocation().then((_) {
                // Önce konumu al, sonra AlertPage'e git
                if (locationViewModel.latitude != null &&
                    locationViewModel.longitude != null) {
                  Navigator.pushNamed(context, '/alert'); // AlertPage'e git
                } else {
                  // Konum alınamazsa kullanıcıya hata mesajı göster
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Konum bilgisi alınamadı. Lütfen konum iznini kontrol edin.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: theme.scaffoldBackgroundColor,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logo0.png',
                          // Logo path'ini kendi projenize göre güncelleyin
                          height: 180,
                          width: 180,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          HomePageCard(
            icon: Icons.bluetooth,
            title: 'Bluetooth Mesajlaşma',
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.secondaryColor.shade100,
            onTap: () {
              Navigator.pushNamed(context, '/bluetooth');
            },
          ),
          const SizedBox(height: 16),
          HomePageCard(
            icon: Icons.settings,
            title: 'Ayarlar',
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.secondaryColor.shade100,
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const SizedBox(height: 16),
          HomePageCard(
            icon: Icons.info_outline,
            title: 'Proje Hakkında',
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.secondaryColor.shade100,
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          const SizedBox(height: 16),
          HomePageCard(
            icon: Icons.book,
            title: 'KVKK',
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
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.secondaryColor.shade100,
            onTap: () {
              Navigator.pushNamed(context, '/');
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: backgroundColor,
                radius: 28,
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 24),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios,
                  color: theme.primaryColorDark, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
