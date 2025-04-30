import 'package:flutter/material.dart';
import 'package:sesini_duyan_var/views/about_view.dart';
import 'package:sesini_duyan_var/views/bluetooth_chat_view.dart';
import 'package:sesini_duyan_var/views/bluetooth_view.dart';
import 'package:sesini_duyan_var/views/home_view.dart';
import 'package:sesini_duyan_var/views/settings_view.dart';import 'theme/app_theme.dart';
import 'views/login_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();  // Flutter binding'i başlatın
  // Firebase'i başlatın
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/bluetooth': (context) => const BluetoothPage(),
        '/settings': (context) => const SettingsPage(),
        '/about': (context) => const AboutPage(),
        '/chat': (context) => const BluetoothChatPage(),
      },
    );
  }
}



