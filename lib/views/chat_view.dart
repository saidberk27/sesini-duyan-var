// lib/views/chat_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sesini_duyan_var/viewmodels/bluetooth_chat_view_model.dart';

import '../services/bluetooth_service.dart';
import '../models/chat_message.dart';

class ChatView extends StatelessWidget {
  final String deviceId;

  const ChatView({Key? key, required this.deviceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => ChatViewModel(
            bluetoothService: context.read<BluetoothService>(),
            deviceId: deviceId,
          ),
      child: const _ChatViewContent(),
    );
  }
}

class _ChatViewContent extends StatefulWidget {
  const _ChatViewContent({Key? key}) : super(key: key);

  @override
  _ChatViewContentState createState() => _ChatViewContentState();
}

class _ChatViewContentState extends State<_ChatViewContent> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatViewModel>();
    final theme = Theme.of(context);

    if (viewModel.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                viewModel.clearError();
              },
            ),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(viewModel.deviceName),
            Text(
              viewModel.isConnected ? 'Connected' : 'Disconnected',
              style: theme.textTheme.bodySmall?.copyWith(
                color: viewModel.isConnected ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              await viewModel.disconnect();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(viewModel, theme)),
          _buildMessageInput(viewModel, theme),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatViewModel viewModel, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child:
          viewModel.messages.isEmpty
              ? Center(
                child: Text(
                  'No messages yet',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              )
              : ListView.builder(
                controller: _scrollController,
                reverse: true,
                itemCount: viewModel.messages.length,
                itemBuilder: (context, index) {
                  final message = viewModel.messages[index];
                  return _MessageBubble(message: message);
                },
              ),
    );
  }

  Widget _buildMessageInput(ChatViewModel viewModel, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              enabled: viewModel.isConnected,
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color:
                  viewModel.isConnected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send),
              color: theme.colorScheme.onPrimary,
              onPressed:
                  viewModel.isConnected
                      ? () => _sendMessage(_messageController.text)
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isNotEmpty) {
      final viewModel = context.read<ChatViewModel>();
      viewModel.sendMessage(text);
      _messageController.clear();
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color:
                  message.isMe
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        message.isMe
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.time),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        message.isMe
                            ? theme.colorScheme.onPrimary.withOpacity(0.7)
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
