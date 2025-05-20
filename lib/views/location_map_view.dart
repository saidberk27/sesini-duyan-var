// lib/views/konum_harita_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // LatLng2 için
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart'; // Bu satır MapController için gerekli
import '../viewmodels/location_map_model.dart'; // ViewModel dosyanızın yolu

class KonumHaritaView extends StatefulWidget {
  const KonumHaritaView({Key? key}) : super(key: key);

  @override
  _KonumHaritaViewState createState() => _KonumHaritaViewState();
}

class _KonumHaritaViewState extends State<KonumHaritaView> {
  final MapController _mapController = MapController(); // flutter_map için MapController
  bool _isDisposed = false; // Widget'ın dispose edilip edilmediğini takip etmek için

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback, widget'ın ilk frame'i çizildikten sonra kodun çalışmasını sağlar.
    // Bu, build metodu tamamlandıktan sonra notifyListeners() çağrılmasını garantiler.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) { // Widget dispose edilmediyse işlem yap
        final KonumHaritaViewModel viewModel = Provider.of<KonumHaritaViewModel>(context, listen: false);
        viewModel.setMapController(_mapController); // ViewModel'a MapController'ı ver
        viewModel.kullaniciMevcutKonumunuBul(); // Konum bulma işlemini başlat
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true; // Widget dispose edildiğinde işaretle
    _mapController.dispose(); // MapController'ı dispose etmeyi unutma
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ViewModel'ı burada dinliyoruz, Consumer aracılığıyla rebuild olmasını sağlıyoruz
    // Provider.of<KonumHaritaViewModel>(context) çağrısını build metodunun başında tutmak,
    // widget ağacının her yeniden çiziminde güncel ViewModel'a erişimi sağlar.
    final KonumHaritaViewModel konumHaritaViewModel = Provider.of<KonumHaritaViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Konumları'),
        centerTitle: true,
      ),
      body: Consumer<KonumHaritaViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.yukleniyor && viewModel.kullaniciKonumMarkerlari.isEmpty) {
            // Sadece ilk yüklemede veya markerlar boşken yükleniyor göster
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.hataMesaji.isNotEmpty) {
            return Center(child: Text('Hata: ${viewModel.hataMesaji}'));
          } else {
            // Kullanıcı konumu hala null olabilir, bu durumda varsayılan Ankara konumunu kullan.
            final LatLng initialMapCenter = viewModel.kullaniciMevcutKonumGeolocator != null
                ? LatLng(viewModel.kullaniciMevcutKonumGeolocator!.latitude, viewModel.kullaniciMevcutKonumGeolocator!.longitude)
                : viewModel.ankaraLatLng2; // ViewModel'dan doğru varsayılan konuma erişim

            return FlutterMap(
              mapController: _mapController, // MapController'ı buraya atıyoruz
              options: MapOptions(
                initialCenter: initialMapCenter,
                initialZoom: KonumHaritaViewModel.haritaZoomSeviyesi, // Static değişkene doğru erişim
                // onTap: (tapPosition, point) => print('Harita tıklandı: $point'), // İsteğe bağlı
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.your_app_name', // BURAYA KENDİ PAKET ADINIZI YAZIN
                ),
                MarkerLayer(
                  markers: viewModel.kullaniciKonumMarkerlari, // ViewModel'dan gelen Marker listesi
                ),
              ],
            );
          }
        },
      ),
    );
  }
}