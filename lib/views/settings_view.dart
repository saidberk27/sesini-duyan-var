import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayarlar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSettingsGroup(
            title: 'Genel Ayarlar',
            children: [
              _buildSettingsItem(
                title: 'Deprem Tespiti',
                subtitle: 'Sensör verilerinin takip edilmesine izin ver',
                value: earthquakeDetection,
                onChanged: (val) => setState(() => earthquakeDetection = val),
              ),
              _buildSettingsItem(
                title: 'Konum Paylaşımı',
                subtitle: 'Deprem anında konumumu ana sunucuya gönder',
                value: sendLocation,
                onChanged: (val) => setState(() => sendLocation = val),
              ),
              _buildSettingsItem(
                title: 'Bluetooth Mesajlaşma',
                subtitle: 'Bluetooth ile mesaj gönderilmesine izin ver',
                value: bluetoothMessaging,
                onChanged: (val) => setState(() => bluetoothMessaging = val),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsGroup(
            title: 'Sensör Verileri',
            children: [
              ExpansionTile(
                title: const Text(
                  'Kullanılan Sensörler ve Demo Veriler',
                  style: TextStyle(fontSize: 15),
                ),
                initiallyExpanded: sensorsExpanded,
                onExpansionChanged: (expanded) {
                  setState(() => sensorsExpanded = expanded);
                },
                children: [
                  _buildSensorItem(
                    icon: Icons.speed,
                    title: 'İvme Ölçer',
                    value: 'X: 0.12, Y: -0.05, Z: 9.81 m/s²',
                  ),
                  _buildSensorItem(
                    icon: Icons.rotate_right,
                    title: 'Jiroskop',
                    value: 'X: 0.01, Y: 0.00, Z: -0.02 rad/s',
                  ),
                  _buildSensorItem(
                    icon: Icons.explore,
                    title: 'Manyetik Alan Sensörü',
                    value: 'X: 30, Y: -47, Z: 12 μT',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSensorItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}