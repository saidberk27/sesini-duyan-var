import 'package:flutter/material.dart';

class BluetoothChatPage extends StatefulWidget {
  const BluetoothChatPage({super.key});

  @override
  State<BluetoothChatPage> createState() => _BluetoothChatPageState();
}

class _BluetoothChatPageState extends State<BluetoothChatPage> {
  final TextEditingController _controller = TextEditingController();

  // Örnek mesajlar
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Orada kimse var mı?', 'isMe': false},
    {'text': 'Evet, enkaz altında bekliyoruz. Mutfak tarafındayız, kanamalı yaramız yok.', 'isMe': true},
    {'text': 'Anlaşıldı, sizin için geliyoruz.', 'isMe': false},

  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Row(
          children: [
            const Icon(Icons.bluetooth, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'AFAD Ekibi 1',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['isMe'] as bool;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isMe
                          ? theme.primaryColor.withOpacity(0.85)
                          : theme.colorScheme.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: isMe ? Colors.white : theme.textTheme.bodyLarge?.color,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: theme.cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Mesaj yaz...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.primaryColorLight.withOpacity(0.2),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: theme.primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      // Şimdilik mesaj gönderme yok, backend eklenince burası doldurulacak
                    },
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