import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool earthquakeDetection = true;
  bool sendLocation = false;
  bool bluetoothMessaging = false;
  bool sensorsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: theme.primaryColor,
      ),
      body: Container(
        color: const Color(0xFFFFE306),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Deprem tespiti için sensör verilerinin takip edilmesine izin ver'),
              value: earthquakeDetection,
              onChanged: (val) => setState(() => earthquakeDetection = val),
              activeColor: theme.primaryColor,
            ),
            SwitchListTile(
              title: const Text('Deprem anında konumumu ana sunucuya gönder'),
              value: sendLocation,
              onChanged: (val) => setState(() => sendLocation = val),
              activeColor: theme.primaryColor,
            ),
            SwitchListTile(
              title: const Text('Bluetooth ile mesaj gönderilmesine izin ver'),
              value: bluetoothMessaging,
              onChanged: (val) => setState(() => bluetoothMessaging = val),
              activeColor: theme.primaryColor,
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Kullanılan Sensörler ve Demo Veriler'),
              initiallyExpanded: sensorsExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  sensorsExpanded = expanded;
                });
              },
              children: [
                ListTile(
                  title: const Text('İvme Ölçer'),
                  subtitle: const Text('X: 0.12, Y: -0.05, Z: 9.81 m/s²'),
                  leading: const Icon(Icons.speed),
                ),
                ListTile(
                  title: const Text('Jiroskop'),
                  subtitle: const Text('X: 0.01, Y: 0.00, Z: -0.02 rad/s'),
                  leading: const Icon(Icons.rotate_right),
                ),
                ListTile(
                  title: const Text('Manyetik Alan Sensörü'),
                  subtitle: const Text('X: 30, Y: -47, Z: 12 μT'),
                  leading: const Icon(Icons.explore),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}