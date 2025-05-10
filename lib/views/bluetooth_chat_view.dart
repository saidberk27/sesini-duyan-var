import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../viewmodels/bluetooth_chat_view_model.dart';
import '../services/bluetooth_service.dart';

class BluetoothChatPage extends StatelessWidget {
  final BluetoothDevice? initialDevice;

  const BluetoothChatPage({super.key, this.initialDevice});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BluetoothChatViewModel(initialDevice: initialDevice),
      child: const _BluetoothChatView(),
    );
  }
}

class _BluetoothChatView extends StatefulWidget {
  const _BluetoothChatView();

  @override
  State<_BluetoothChatView> createState() => _BluetoothChatViewState();
}

class _BluetoothChatViewState extends State<_BluetoothChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // _showDeviceListDialog metodu bu sayfadan kaldırıldı, BluetoothPage'de.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = Provider.of<BluetoothChatViewModel>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.messages.isNotEmpty) _scrollToBottom();
    });

    String appBarTitle = 'Bluetooth Sohbet';
    final deviceToDisplay =
        viewModel.selectedDevice; // Bu her zaman initialDevice olacak

    if (deviceToDisplay != null) {
      appBarTitle = deviceToDisplay.name ?? deviceToDisplay.address;
      if (viewModel.connectionState == BluetoothConnectionState.connecting) {
        appBarTitle = "$appBarTitle bağlanıyor...";
      } else if (viewModel.connectionState ==
          BluetoothConnectionState.connected) {
        appBarTitle = "$appBarTitle ile bağlı";
      }
    } else {
      appBarTitle = "Cihaz Seçilmedi"; // initialDevice null ise
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            viewModel.connectionState == BluetoothConnectionState.connected
                ? Colors.green
                : theme.primaryColor,
        title: Row(
          children: [
            Icon(
              viewModel.connectionState == BluetoothConnectionState.connected
                  ? Icons.bluetooth_connected
                  : (viewModel.connectionState ==
                          BluetoothConnectionState.connecting
                      ? Icons
                          .bluetooth_searching_rounded // Bağlanırken farklı ikon
                      : Icons.bluetooth_disabled),
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                appBarTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Tarama butonu buradan kaldırıldı.
          if (viewModel.connectionState == BluetoothConnectionState.connected)
            IconButton(
              icon: const Icon(Icons.link_off, color: Colors.white),
              tooltip: 'Bağlantıyı Kes',
              onPressed: () => viewModel.disconnect(),
            ),
        ],
        elevation: 2,
      ),
      body: Column(
        children: [
          if (viewModel.errorMessage != null)
            Container(
              width: double.infinity,
              color: Colors.red[100],
              padding: const EdgeInsets.all(12.0),
              child: Text(
                viewModel.errorMessage!,
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          // Bağlantı butonu (eğer bağlı değilse ve cihaz seçilmişse)
          if (viewModel.selectedDevice != null &&
              viewModel.connectionState != BluetoothConnectionState.connected &&
              viewModel.connectionState != BluetoothConnectionState.connecting)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bluetooth_searching_rounded),
                label: Text(
                  "${viewModel.selectedDevice!.name ?? viewModel.selectedDevice!.address} Cihazına Bağlan",
                ),
                onPressed: () => viewModel.attemptConnectToSelectedDevice(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          if (viewModel.selectedDevice == null)
            Expanded(
              child: Center(
                child: Text(
                  "Sohbet başlatmak için bir cihaz seçin.",
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),

          Expanded(
            child:
                viewModel.selectedDevice ==
                        null // Cihaz seçilmemişse mesaj listesini gösterme
                    ? const SizedBox.shrink()
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      itemCount: viewModel.messages.length,
                      itemBuilder: (context, index) {
                        final messageData = viewModel.messages[index];
                        final messageText = messageData['text'] as String;
                        final isMe = messageData['isMe'] as bool;
                        final isSystemMessage =
                            messageData['isSystemMessage'] as bool? ?? false;

                        if (isSystemMessage) {
                          return Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                messageText,
                                style: TextStyle(
                                  color: Colors.blueGrey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        return Align(
                          alignment:
                              isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isMe
                                      ? theme.primaryColor
                                      : theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft:
                                    isMe
                                        ? const Radius.circular(20)
                                        : const Radius.circular(4),
                                bottomRight:
                                    isMe
                                        ? const Radius.circular(4)
                                        : const Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              messageText,
                              style: TextStyle(
                                color:
                                    isMe
                                        ? Colors.white
                                        : theme.textTheme.bodyLarge?.color,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          // Mesaj gönderme alanı sadece bağlıyken ve cihaz seçiliyken aktif olmalı
          if (viewModel.connectionState == BluetoothConnectionState.connected &&
              viewModel.selectedDevice != null)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -1),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 8,
                top: 8,
                bottom: MediaQuery.of(context).padding.bottom + 8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Mesajınızı yazın...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (text) {
                        if (viewModel.connectionState ==
                                BluetoothConnectionState.connected &&
                            text.trim().isNotEmpty) {
                          viewModel.sendMessage(text.trim());
                          _messageController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap:
                          viewModel.connectionState ==
                                      BluetoothConnectionState.connected &&
                                  _messageController.text.trim().isNotEmpty
                              ? () {
                                viewModel.sendMessage(
                                  _messageController.text.trim(),
                                );
                                _messageController.clear();
                              }
                              : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(Icons.send, color: Colors.white, size: 24),
                      ),
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
