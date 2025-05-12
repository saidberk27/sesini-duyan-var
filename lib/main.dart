import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sesini_duyan_var/viewmodels/send_location_model.dart';
import 'package:sesini_duyan_var/views/about_view.dart';
import 'package:sesini_duyan_var/views/alert_view.dart';
import 'package:sesini_duyan_var/views/bluetooth_chat_view.dart';
import 'package:sesini_duyan_var/views/bluetooth_chatlist_view.dart';
import 'package:sesini_duyan_var/views/home_view.dart';
import 'package:sesini_duyan_var/views/kvkk_view.dart';
import 'package:sesini_duyan_var/views/settings_view.dart';
import 'package:sesini_duyan_var/views/register_view.dart';
import 'package:sesini_duyan_var/theme/app_theme.dart';
import 'package:sesini_duyan_var/views/login_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sesini_duyan_var/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SendLocationViewModel()),
        // Diğer provider'lar buraya eklenebilir.
      ],
      child: MaterialApp(
        title: 'Sesini Duyan Var',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
          '/bluetooth': (context) => const BluetoothPage(),
          '/settings': (context) => const SettingsPage(),
          '/about': (context) => const AboutPage(),
          '/chat': (context) => const BluetoothChatPage(),
          '/alert': (context) => const AlertPage(),
          '/kvkk': (context) => const KvkkPage(),
        },
      ),
    );
  }
}
