// lib/views/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sesini_duyan_var/theme/app_theme.dart';

import 'package:sesini_duyan_var/viewmodels/location_map_model.dart';
import 'package:sesini_duyan_var/views/location_map_view.dart';

import 'package:sesini_duyan_var/utils/earthquake_detector.dart'; // Import the new file

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late EarthquakeDetector _earthquakeDetector;

  // Ayarlanabilir ivme eşiği (m/s^2)
  // Ayarlanabilir açısal hız eşiği (rad/s)
  // Ayarlanabilir süre eşiği

  @override
  void initState() {
    super.initState();
    _earthquakeDetector = Provider.of<EarthquakeDetector>(
      context,
      listen: false,
    );
    _earthquakeDetector.onEarthquakeDetected = _navigateToAlert;
    _earthquakeDetector.startListening();
  }

  @override
  void dispose() {
    _earthquakeDetector.stopListening();
    super.dispose();
  }

  void _navigateToAlert() {
    if (mounted) {
      // Stop listening to sensors before navigating to alert page
      _earthquakeDetector.stopListening();
      Navigator.pushNamed(context, '/alert').then((_) {
        // After returning from AlertPage, restart listening
        _earthquakeDetector.startListening();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Main Logo and App Name Section
          Card(
            elevation: 2,
            color: theme.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(
              bottom: 24,
            ), // Increased margin for separation
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo0.png',
                    height: 200,
                    width: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey,
                      );
                    },
                  ),
                  const SizedBox(height: 16), // Spacing between logo and text
                ],
              ),
            ),
          ),
          // User Locations Card (now using HomePageCard)
          HomePageCard(
            icon: Icons.location_on,
            title: 'Kullanıcı Konumları',
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.secondaryColor.shade100,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => ChangeNotifierProvider(
                        create: (context) => KonumHaritaViewModel(),
                        child: const KonumHaritaView(),
                      ),
                ),
              );
            },
          ),
          const SizedBox(height: 16), // Spacing between cards
          // --- BLUETOOTH MESAJLAŞMA KARTI BİTİŞ ---
          HomePageCard(
            icon: Icons.person_outline_rounded,
            title: 'Bluetooth Mesajlaşma & Elektronik Düdük',
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.secondaryColor.shade100,
            onTap: () {
              Navigator.pushNamed(context, '/bluetooth');
            },
          ),
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
