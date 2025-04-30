import 'package:flutter/material.dart';

class KvkkPage extends StatelessWidget {
  const KvkkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kişisel Verilerin Korunması',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son Değişiklik Tarihi: 20 Nisan 2025',
              style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Text(
              'Bu aydınlatma metni, "Sesini Duyan Var" mobil uygulamasını kullanmanız sırasında kişisel verilerinizin işlenmesi hakkında sizi bilgilendirmek amacıyla hazırlanmıştır. Uygulamamızı kullanarak aşağıda belirtilen kişisel verilerinizin işlenmesini kabul etmiş olursunuz.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // 1. İşlenen Kişisel Verileriniz
            Text(
              '1. İşlenen Kişisel Verileriniz',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Uygulamamız tarafından, uygulamanın işlevselliğini sağlamak ve acil durumlarda size yardımcı olmak amacıyla aşağıdaki kişisel verileriniz işlenmektedir:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListItem(context, 'Kimlik ve İletişim Bilgileri: Kullanıcı Adı, E Posta, Kullanıcı Yaşı, Kullanıcı Cinsiyeti, Kullanıcı Aile Bireyleri, Kullanıcı Aile Bireyleri İletişim Numarası, Kullanıcı Adresi, Kullanıcı Telefon Numarası, Kullanıcı Bluetooth Kimliği.'),
                  _buildListItem(context, 'Konum Verileri: GPS ve ağ tabanlı konum servislerinden alınan enlem, boylam, doğruluk, zaman damgası gibi bilgiler.'),
                  _buildListItem(context, 'Sensör Verileri: İvmeölçer ve jiroskop sensörlerinden alınan ham zaman serisi verileri (geçici olarak işlenir).'),
                  _buildListItem(context, 'Bluetooth Ağ Bilgileri: Bluetooth Mesh ağındaki cihaz listesi, ID\'leri, bağlantı durumları, mesajlaşma oturumları.'),
                  _buildListItem(context, 'Mesaj İçerikleri: Bluetooth mesajlaşması aracılığıyla gönderdiğiniz mesajların içeriği.'),
                  _buildListItem(context, 'Uygulama Ayarları: Uygulama içi tercihleriniz ve ayarlarınız.'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Kişisel Verilerinizin İşlenme Amaçları
            Text(
              '2. Kişisel Verilerinizin İşlenme Amaçları',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Kişisel verileriniz, aşağıdaki amaçlarla işlenmektedir:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListItem(context, 'Deprem anını tespit etmek ve sizi bilgilendirmek.'),
                  _buildListItem(context, 'Deprem anında konumunuzu belirlemek ve acil durum yetkilileri veya belirlediğiniz kişilerle (kurtarma amaçlı) paylaşmak.'),
                  _buildListItem(context, 'Bluetooth Mesh ağı üzerinden çevrimdışı iletişimi sağlamak.'),
                  _buildListItem(context, 'Uygulama içi ayarlarınızı kaydetmek ve yönetmek.'),
                  _buildListItem(context, 'Uygulamanın performansını analiz etmek ve geliştirmek.'),
                  _buildListItem(context, 'Size daha iyi bir kullanıcı deneyimi sunmak.'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Kişisel Verilerinizin Aktarılması
            Text(
              '3. Kişisel Verilerinizin Aktarılması',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Kişisel verileriniz, yukarıda belirtilen amaçlar doğrultusunda ve yalnızca gerektiği ölçüde aşağıdaki üçüncü kişilerle paylaşılabilecektir:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListItem(context, 'Acil Durum Yetkilileri: Deprem anında konum verileriniz, kurtarma çalışmalarına destek olmak amacıyla ilgili acil durum yetkilileriyle paylaşılabilir.'),
                  _buildListItem(context, 'Belirlediğiniz Kişiler: Uygulama ayarlarınızda belirlediğiniz kişilerle (örneğin aile bireyleri) deprem anında konumunuz paylaşılabilir.'),
                  _buildListItem(context, 'Teknik Servis Sağlayıcıları: Uygulamanın çalışması için kullandığımız teknik altyapı sağlayıcıları (örneğin Firebase Firestore) ile verileriniz paylaşılabilir. Bu sağlayıcılar, verilerinizi kendi gizlilik politikaları doğrultusunda işleyebilirler.'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kişisel verileriniz, yasal yükümlülükler gereği veya resmi kurumların talebi üzerine ilgili makamlarla da paylaşılabilecektir.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // 4. Kişisel Verilerinizin Saklanması ve Güvenliği
            Text(
              '4. Kişisel Verilerinizin Saklanması ve Güvenliği',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Kişisel verileriniz, işlenme amaçlarının gerektirdiği süre boyunca saklanacaktır. Sensör ve geçici konum verileri işlendikten sonra silinir. Diğer veriler (kimlik, iletişim, Bluetooth bilgileri, mesajlar, ayarlar) uygulamanın kullanımı süresince saklanır.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Verilerinizin güvenliği için gerekli teknik ve idari tedbirler alınmaktadır. Özellikle konum verileriniz Firebase Firestore güvenlik kuralları ile korunmakta ve Bluetooth iletişimi için temel şifreleme mekanizmaları kullanılmaktadır. Ancak, internet üzerinden yapılan veri aktarımlarının tam güvenliğinin sağlanamayacağını unutmamanız önemlidir.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // 5. Kişisel Verilerinize İlişkin Haklarınız
            Text(
              '5. Kişisel Verilerinize İlişkin Haklarınız',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'KVKK\'nın 11. maddesi uyarınca kişisel verilerinize ilişkin aşağıdaki haklara sahipsiniz:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListItem(context, 'Kişisel verilerinizin işlenip işlenmediğini öğrenme.'),
                  _buildListItem(context, 'Kişisel verileriniz işlenmişse buna ilişkin bilgi talep etme.'),
                  _buildListItem(context, 'Kişisel verilerinizin işlenme amacını ve bunların amacına uygun kullanılıp kullanılmadığını öğrenme.'),
                  _buildListItem(context, 'Yurt içinde veya yurt dışında kişisel verilerinizin aktarıldığı üçüncü kişileri bilme.'),
                  _buildListItem(context, 'Kişisel verilerinizin eksik veya yanlış işlenmiş olması halinde bunların düzeltilmesini isteme.'),
                  _buildListItem(context, 'KVKK\'nın 7. maddesinde öngörülen şartlar çerçevesinde kişisel verilerinizin silinmesini veya yok edilmesini isteme.'),
                  _buildListItem(context, 'Yukarıda belirtilen düzeltme, silme veya yok etme işlemlerinin, kişisel verilerinizin aktarıldığı üçüncü kişilere bildirilmesini isteme.'),
                  _buildListItem(context, 'İşlenen verilerinizin münhasıran otomatik sistemler vasıtasıyla analiz edilmesi suretiyle aleyhinize bir sonucun ortaya çıkmasına itiraz etme.'),
                  _buildListItem(context, 'Kişisel verilerinizin kanuna aykırı olarak işlenmesi sebebiyle zarara uğramanız halinde zararın giderilmesini talep etme.'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu haklarınızı kullanmak için [İletişim Bilgileri - Buraya projenizle ilgili bir e-posta adresi veya iletişim kanalı eklenebilir] üzerinden bizimle iletişime geçebilirsiniz.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // 6. Değişiklikler
            Text(
              '6. Değişiklikler',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu aydınlatma metni, yasal düzenlemeler ve uygulama geliştirmeleri doğrultusunda güncellenebilir. Güncellemeler uygulamamız içinde veya web sitemizde (eğer varsa) duyurulacaktır.',
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 10),
            Text(
              'Uygulamayı İndirip Kullandığınız Andan İtibaren KVKK Şartlarını Kabul Etmiş Sayılırsınız.',
              style: theme.textTheme.bodyLarge!.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: Theme.of(context).textTheme.bodyMedium),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}