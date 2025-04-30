import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  // GitHub linkini açmak için fonksiyon
  Future<void> _launchGitHubUrl() async {
    final Uri url = Uri.parse('https://github.com/saidberk27/sesini-duyan-var');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildInfoCard({required String title, required Widget content}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Proje Hakkında',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
        elevation: 2,    
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: 'Proje Adı:',
              content: Text(
                'Sesini Duyan Var',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            _buildInfoCard(
              title: 'Proje Açıklaması:',
              content: Text(
                ' "Sesini Duyan Var" uygulaması, BM-314 Yazılım Mühendisliği dönem projesi kapsamında, deprem anında ve sonrasında kullanıcılara yardımcı olmak amacıyla geliştirilen bir mobil uygulamadır. Uygulama, sismik aktiviteyi cep telefonu düzeyinde tespit etmek, deprem tespit edildiği anda kullanıcı konumunu otomatik olarak kurtarma amaçlı paylaşmak ve özellikle internet ve mobil ağların kullanılamaz olduğu acil durumlarda Bluetooth üzerinden çevrimdışı iletişimi etkinleştirmek için akıllı telefon özelliklerinden yararlanmayı amaçlamaktadır.\n\nProjenin temel amacı, deprem sırasında ve sonrasında konum bilgisi güvenliği ve iletişimi önemli ölçüde artırabilecek kullanıcı dostu ve güvenilir bir uygulama oluşturmaktır. Deprem tespiti, konum paylaşımı ve Bluetooth mesajlaşmasını entegre ederek "Sesini Duyan Var", bireylerin afet esnasında örgütlenmesini, enkaz altı haritalandırılmasını gerçekleştirmeyi ve afet senaryolarında kurtarma çalışmalarına yardımcı olmayı hedeflemektedir.',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            _buildInfoCard(
              title: 'Ders Bilgileri:',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ders Kodu: BM-314',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    'Ders Adı: Yazılım Mühendisliği',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    'Proje Hocası: Prof. Dr. Hacer Karacan',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            _buildInfoCard(
              title: 'Geliştirme Ekibi:',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ali Özen (21118080029)',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    'Ceren Akmeşe (22118080701)',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    'Merve Keleş (21118080762)',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    'Said Berk (21118080070)',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            _buildInfoCard(
              title: 'GitHub Linki:',
              content: InkWell(
                onTap: _launchGitHubUrl,
                child: Text(
                  'https://github.com/saidberk27/sesini-duyan-var',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}