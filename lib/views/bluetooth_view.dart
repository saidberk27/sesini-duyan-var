import 'package:flutter/material.dart';
import 'package:sesini_duyan_var/views/bluetooth_chat_view.dart';

class BluetoothPage extends StatelessWidget {
  const BluetoothPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Örnek kişi ve sohbet listesi
    final List<Map<String, String>> chats = [
      {'name': 'AFAD Ekibi 1', 'lastMessage': 'Anlaşıldı, sizin için geliyoruz.', 'time': '12:30'},
      {'name': 'İtfaiye', 'lastMessage': 'Bekliyoruz!', 'time': '11:15'},
      {'name': 'Tıbbi Ekip', 'lastMessage': 'Hayır, baş dönmesi mevcut değil.', 'time': 'Dün'},
      {'name': 'Hakan', 'lastMessage': 'Tam üstümüzdeler sesleri duyuyorum.', 'time': 'Dün'},
   
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Row(
          children: [
            const Icon(Icons.bluetooth, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Bluetooth Sohbetler',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
        elevation: 2,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chats.length,
        // Separator builder ile özelleştirilmiş divider
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            height: 0,
            thickness: 2,
          
          ),
        ),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: theme.primaryColorLight,
              child: Text(
                chat['name']![0],
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              chat['name']!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                chat['lastMessage']!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat['time']!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BluetoothChatPage(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}