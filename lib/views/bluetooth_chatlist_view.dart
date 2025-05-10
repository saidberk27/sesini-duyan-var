import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/bluetooth_chatlist_view_model.dart';
import './bluetooth_chat_view.dart'; // BluetoothChatPage'in bulunduğu dosya

class BluetoothPage extends StatelessWidget {
  const BluetoothPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BluetoothListViewModel(),
      child: const _BluetoothListView(),
    );
  }
}

class _BluetoothListView extends StatelessWidget {
  const _BluetoothListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = Provider.of<BluetoothListViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Row(
          children: [
            const Icon(Icons.bluetooth_searching_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Yakındaki Cihazlar',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              viewModel.isDiscovering
                  ? Icons.stop_circle_outlined
                  : Icons.search,
              color: Colors.white,
            ),
            tooltip:
                viewModel.isDiscovering ? 'Taramayı Durdur' : 'Cihazları Tara',
            onPressed: () {
              if (viewModel.isDiscovering) {
                viewModel.stopDiscovery();
              } else {
                viewModel.startDiscovery();
              }
            },
          ),
        ],
        elevation: 2,
      ),
      body: Column(
        children: [
          if (viewModel.isDiscovering) const LinearProgressIndicator(),
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
          if (viewModel.discoveredDevices.isEmpty &&
              !viewModel.isDiscovering &&
              viewModel.errorMessage == null)
            Expanded(
              // Ortalamak için Expanded ve Center
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Yakınlarda Bluetooth cihazı bulunamadı. Taramayı başlatmak için yukarıdaki arama ikonuna dokunun.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: viewModel.discoveredDevices.length,
              separatorBuilder:
                  (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(
                      height: 0,
                      thickness: 1,
                      color: Colors.grey[300],
                    ),
                  ),
              itemBuilder: (context, index) {
                final result = viewModel.discoveredDevices[index];
                final device = result.device;
                // result.rssi null olamayacağı varsayımıyla null kontrolü kaldırıldı.
                final String rssiText = "${result.rssi} dBm";

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ), // Padding'i artırdım
                  leading: CircleAvatar(
                    backgroundColor: theme.primaryColor.withOpacity(
                      0.1,
                    ), // Rengi açtım
                    child: Icon(Icons.bluetooth, color: theme.primaryColor),
                  ),
                  title: Text(
                    device.name ?? "Bilinmeyen Cihaz",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ), // Kalınlaştırdım
                  ),
                  subtitle: Text(device.address),
                  trailing: Text(
                    rssiText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  onTap: () {
                    viewModel
                        .stopDiscovery(); // Sohbet sayfasına gitmeden önce taramayı durdur
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // BluetoothChatPage'e seçilen cihazı iletiyoruz
                        builder:
                            (context) =>
                                BluetoothChatPage(initialDevice: device),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
