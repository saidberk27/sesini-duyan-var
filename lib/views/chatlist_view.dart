import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sesini_duyan_var/models/connected_device.dart';
import 'package:sesini_duyan_var/viewmodels/bluetooth_chatlist_view_model.dart';
import 'package:sesini_duyan_var/views/chat_view.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatListViewModel>();
    final theme = Theme.of(context);
    // Hata varsa göster
    if (viewModel.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      });
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Chat'), elevation: 0),
      body: Column(
        children: [
          _buildControlButtons(context, theme, viewModel),
          _buildDevicesList(context, theme, viewModel),
        ],
      ),
    );
  }

  Widget _buildControlButtons(
    BuildContext context,
    ThemeData theme,
    ChatListViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ), // Padding'i azalttık
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            // Expanded ekledik
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildActionButton(
                context,
                title:
                    viewModel.isAdvertising
                        ? 'Stop'
                        : 'Start', // Metni kısalttık
                subtitle: 'Advertising', // Alt metin ekleyebilirsiniz
                icon: Icons.broadcast_on_personal,
                isActive: viewModel.isAdvertising,
                onPressed:
                    () => viewModel.toggleAdvertising(
                      "User-${DateTime.now().millisecondsSinceEpoch}",
                    ),
              ),
            ),
          ),
          Expanded(
            // Expanded ekledik
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildActionButton(
                context,
                title:
                    viewModel.isDiscovering
                        ? 'Stop'
                        : 'Start', // Metni kısalttık
                subtitle: 'Discovery', // Alt metin ekleyebilirsiniz
                icon: Icons.search,
                isActive: viewModel.isDiscovering,
                onPressed:
                    () => viewModel.toggleDiscovery(
                      "User-${DateTime.now().millisecondsSinceEpoch}",
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    String? subtitle, // subtitle parametresini ekledik
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return SizedBox(
      height: subtitle != null ? 50 : 40, // subtitle varsa yüksekliği artır
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isActive ? theme.colorScheme.error : theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 8 : 12,
            vertical: isSmallScreen ? 8 : 10,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isSmallScreen ? 18 : 20),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: isSmallScreen ? 12 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: isSmallScreen ? 10 : 11,
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesList(
    BuildContext context,
    ThemeData theme,
    ChatListViewModel viewModel,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Connected Devices',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child:
                  viewModel.connectedDevices.isEmpty
                      ? Center(
                        child: Text(
                          'No devices connected',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: viewModel.connectedDevices.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final device = viewModel.connectedDevices[index];
                          return _buildDeviceItem(
                            context,
                            device,
                            theme,
                            viewModel,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem(
    BuildContext context,
    ConnectedDevice device,
    ThemeData theme,
    ChatListViewModel viewModel,
  ) {
    final isSelected = device.id == viewModel.selectedDeviceId;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withOpacity(0.2),
        child: Icon(
          Icons.devices,
          color:
              isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
        ),
      ),
      title: Text(device.name, style: theme.textTheme.titleMedium),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        viewModel.selectDevice(device.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatView(deviceId: device.id),
          ),
        );
      },
    );
  }
}
