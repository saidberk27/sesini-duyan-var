import 'dart:async'; // Timer için
import 'dart:ui'; // DartPluginRegistrant.ensureInitialized() için

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Tarih formatlama için

// Flutter Background Service için eklendi
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart'; // Android için eklendi

// Arka planda kullanılacak diğer paketler
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sesini_duyan_var/firebase_options.dart';
import 'package:sesini_duyan_var/viewmodels/send_location_model.dart';
import 'package:sesini_duyan_var/viewmodels/user_profile_view_model.dart';
import 'package:sesini_duyan_var/theme/app_theme.dart';

// Kendi servis ve model dosyalarınızın yolları
// Bu importlar onStart fonksiyonu içinde kullanılacak
import 'package:sesini_duyan_var/services/firestore_service.dart';
import 'package:sesini_duyan_var/models/location_data_model.dart';

// View importları
import 'package:sesini_duyan_var/views/login_view.dart';
import 'package:sesini_duyan_var/views/register_view.dart';
import 'package:sesini_duyan_var/views/home_view.dart';
import 'package:sesini_duyan_var/views/bluetooth_chatlist_view.dart'; // BluetoothPage -> BluetoothChatListView olarak varsayılmıştı
import 'package:sesini_duyan_var/views/settings_view.dart';
import 'package:sesini_duyan_var/views/user_profile_view.dart';
import 'package:sesini_duyan_var/views/about_view.dart';
import 'package:sesini_duyan_var/views/bluetooth_chat_view.dart';
import 'package:sesini_duyan_var/views/alert_view.dart';
import 'package:sesini_duyan_var/views/kvkk_view.dart';

// --- Flutter Background Service Handler ve Sabitler ---
// SharedPreferences'ta userId'yi saklamak için kullanılacak anahtar
// Bu anahtar SendLocationViewModel'deki ile aynı olmalı.
const String userIdSharedPrefKey =
    'current_user_id_for_background'; // Canvas'taki gibi

// Arka plan servisi başladığında çağrılacak olan asıl fonksiyon
@pragma('vm:entry-point') // Bu satır önemli!
Future<void> onStart(ServiceInstance service) async {
  // Bu satırın Dart'ın yerel kodlarla etkileşim kurabilmesini sağladığından emin olun.
  // Genellikle sadece arka plan isolate'lerinde gereklidir.
  DartPluginRegistrant.ensureInitialized();

  // BURADAN Firebase.initializeApp() ÇAĞRISINI KALDIRDIK.
  // Firebase, uygulamanın main() fonksiyonunda zaten başlatılıyor.
  // Arka plan hizmeti, ana isolate'te başlatılan Firebase instance'ını kullanabilir.
  print("BackgroundService: Arka plan servisi başlatıldı.");

  // Android'e özel Foreground/Background servis geçişleri (isteğe bağlı)
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  // Periyodik görev (konum güncelleme)
  // Timer.periodic(const Duration(minutes: 1), (timer) async { // Test için 1 dakika
  Timer.periodic(const Duration(hours: 1), (timer) async {
    print("BackgroundService: Periyodik görev tetiklendi - ${DateTime.now()}");

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString(userIdSharedPrefKey);

      if (userId == null || userId.isEmpty) {
        print(
          "BackgroundService: Kayıtlı kullanıcı ID'si bulunamadı. Konum gönderilmeyecek.",
        );
        return;
      }
      print(
        "BackgroundService: Kullanıcı ID SharedPreferences'tan alındı: $userId",
      );

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("BackgroundService: Konum servisi kapalı.");
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("BackgroundService: Konum izni yok.");
        return;
      }

      print("BackgroundService: Konum alınıyor...");
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print(
        "BackgroundService: Konum alındı: ${position.latitude}, ${position.longitude}",
      );

      final locationData = LocationDataModel(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: Timestamp.now(),
        userId: userId,
        // deviceId: null, // deviceId kullanmıyorsanız ve modelinizde nullable ise
      );

      final FirestoreService firestoreService = FirestoreService();
      await firestoreService.updateUserLocationAsFields(locationData);
      print(
        "BackgroundService: Konum Firestore'a başarıyla gönderildi (Kullanıcı: $userId).",
      );
    } catch (e, stacktrace) {
      print("BackgroundService: Periyodik görevde HATA oluştu: $e");
      print("BackgroundService: Hata StackTrace: $stacktrace");
    }
  });

  service.invoke("service_started", {
    "message": "Arka plan konumu servisi aktif.",
  });
}

// Arka plan servisini yapılandırma ve başlatma fonksiyonu
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true, // Uygulama açıldığında servisin otomatik başlaması için
      // initialNotificationTitle: 'Konum Servisi Aktif', // Bildirim başlığı
      // initialNotificationContent: 'Konumunuz periyodik olarak güncelleniyor.', // Bildirim içeriği
      // foregroundServiceNotificationId: 888, // Benzersiz bildirim ID'si
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true, // Uygulama açıldığında otomatik başlaması için
      onForeground: onStart,
      // onBackground: onIosBackground, // iOS için özel bir arka plan handler (gerekirse)
    ),
  );
  // autoStart:true ise bu satıra genellikle gerek kalmaz, ancak emin olmak için eklenebilir veya kaldırılabilir.
  // service.startService();
  print("FlutterBackgroundService yapılandırıldı ve başlatılması bekleniyor.");
}
// --- Flutter Background Service Handler ve Sabitler Bitiş ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i burada, ana isolate'te BİR KEZ başlatın.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('tr_TR', null); // Türkçe tarih formatı için

  // Flutter Background Service'i başlat
  // Firebase başlatıldıktan sonra çağrılmasında sorun yoktur.
  await initializeBackgroundService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SendLocationViewModel()),
        ChangeNotifierProvider(create: (_) => UserProfileViewModel()),
      ],
      child: MaterialApp(
        title: 'Sesini Duyan Var',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations
              .delegate, // Cupertino widget'ları için (isteğe bağlı)
        ],
        supportedLocales: const [
          Locale('tr', 'TR'), // Türkçe desteği
          Locale(
            'en',
            'US',
          ), // İngilizce desteği (varsayılan veya fallback olarak)
          // Diğer desteklemek istediğiniz dilleri buraya ekleyebilirsiniz
        ],
        locale: const Locale('tr', 'TR'),
        routes: {
          '/': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
          '/bluetooth':
              (context) =>
          const BluetoothPage(), // BluetoothPage'i kendi sayfanızla değiştirin
          '/settings': (context) => const SettingsPage(),
          '/profile': (context) => const UserProfilePage(),
          '/about': (context) => const AboutPage(),
          '/chat': (context) => const BluetoothChatPage(),
          '/alert': (context) => const AlertPage(),
          '/kvkk': (context) => const KvkkPage(),
        },
      ),
    );
  }
}

// iOS için özel bir arka plan handler (eğer gerekirse ve ayrı bir dosyada değilse)
// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();
//   print('FLUTTER BACKGROUND SERVICE: iOS BG');
//   return true;
// }