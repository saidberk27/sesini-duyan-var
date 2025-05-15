import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sesini_duyan_var/viewmodels/user_profile_view_model.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _emailPasswordController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _newEmailController.dispose();
    _emailPasswordController.dispose();
    super.dispose();
  }

  void _showUpdateDialog(
    BuildContext context,
    String title,
    Widget content,
    Future<void> Function() onSave, {
    bool dismissibleOnSave = true,
  }) {
    final viewModel = Provider.of<UserProfileViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: content),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                viewModel.clearMessages();
              },
            ),
            ElevatedButton(
              child: const Text('Kaydet'),
              onPressed: () async {
                await onSave();
                if (dismissibleOnSave && viewModel.successMessage != null) {
                  if (Navigator.canPop(dialogContext)) {
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _handleViewModelMessages(UserProfileViewModel viewModel) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        viewModel.clearMessages();
      }
      if (viewModel.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        viewModel.clearMessages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserProfileViewModel>(context);
    _handleViewModelMessages(viewModel);

    if (viewModel.userData != null) {
      if (_firstNameController.text.isEmpty &&
          (viewModel.userData!.firstName?.isNotEmpty ?? false)) {
        _firstNameController.text = viewModel.userData!.firstName!;
      }
      if (_lastNameController.text.isEmpty &&
          (viewModel.userData!.lastName?.isNotEmpty ?? false)) {
        _lastNameController.text = viewModel.userData!.lastName!;
      }
      if (_selectedGender == null &&
          (viewModel.userData!.gender?.isNotEmpty ?? false)) {
        _selectedGender = viewModel.userData!.gender;
      }
      if (_selectedDateOfBirth == null &&
          viewModel.userData!.dateOfBirth != null) {
        _selectedDateOfBirth = viewModel.userData!.dateOfBirth!.toDate();
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcı Profilim')),
      body:
          viewModel.isLoading && viewModel.userData == null
              ? const Center(child: CircularProgressIndicator())
              : viewModel.userData == null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        viewModel.errorMessage ??
                            "Kullanıcı bilgileri yüklenemedi. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("Tekrar Dene"),
                        onPressed: () => viewModel.loadUserProfile(),
                      ),
                    ],
                  ),
                ),
              )
              : RefreshIndicator(
                onRefresh: viewModel.loadUserProfile,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: <Widget>[
                    _buildProfileInfoCard(viewModel, context),
                    const SizedBox(height: 20),
                    _buildAccountActionsCard(viewModel, context),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'Çıkış Yap',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        onPressed: () async {
                          // TODO: Çıkış yapma mantığını AuthViewModel veya UserProfileViewModel üzerinden ekle
                          // Örnek: await viewModel.signOut(); // UserProfileViewModel'e signOut metodu ekleyebilirsiniz.
                          // if (mounted) {
                          //   Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                          // }
                          print("Çıkış yap butonuna basıldı.");
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileInfoCard(
    UserProfileViewModel viewModel,
    BuildContext context,
  ) {
    final user = viewModel.userData!;
    final DateFormat dateFormat = DateFormat(
      'dd MMMM yyyy',
      'tr_TR',
    ); // Yıl için yyyy eklendi

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Profil Bilgileri',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),

            _buildInfoTile(
              context,
              Icons.badge_outlined,
              'Ad',
              user.firstName ?? 'Belirtilmemiş',
              onTap: () {
                _firstNameController.text = user.firstName ?? '';
                _showUpdateDialog(
                  context,
                  'Adınızı Güncelleyin',
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'Yeni Adınız'),
                    autofocus: true,
                  ),
                  () async => await viewModel.updateFirstName(
                    _firstNameController.text,
                  ),
                  dismissibleOnSave: true,
                );
              },
            ),

            _buildInfoTile(
              context,
              Icons.badge,
              'Soyad',
              user.lastName ?? 'Belirtilmemiş',
              onTap: () {
                _lastNameController.text = user.lastName ?? '';
                _showUpdateDialog(
                  context,
                  'Soyadınızı Güncelleyin',
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Yeni Soyadınız',
                    ),
                    autofocus: true,
                  ),
                  () async =>
                      await viewModel.updateLastName(_lastNameController.text),
                  dismissibleOnSave: true,
                );
              },
            ),

            _buildInfoTile(
              context,
              Icons.email_outlined,
              'E-posta',
              user.email ?? 'N/A',
            ),

            _buildInfoTile(
              context,
              Icons.wc_outlined,
              'Cinsiyet',
              user.gender ?? 'Belirtilmemiş',
              onTap: () {
                String? dialogSelectedGender = _selectedGender ?? user.gender;
                _showUpdateDialog(
                  context,
                  'Cinsiyeti Güncelle',
                  StatefulBuilder(
                    builder: (
                      BuildContext context,
                      StateSetter setStateDialog,
                    ) {
                      return DropdownButtonFormField<String>(
                        value: dialogSelectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Cinsiyetiniz',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Erkek',
                            child: Text('Erkek'),
                          ),
                          DropdownMenuItem(
                            value: 'Kadın',
                            child: Text('Kadın'),
                          ),
                        ],
                        onChanged: (value) {
                          setStateDialog(() {
                            dialogSelectedGender = value;
                          });
                        },
                      );
                    },
                  ),
                  () async {
                    if (dialogSelectedGender != null) {
                      await viewModel.updateGender(dialogSelectedGender!);
                    }
                  },
                  dismissibleOnSave: true,
                );
              },
            ),

            _buildInfoTile(
              context,
              Icons.cake_outlined,
              'Doğum Tarihi',
              user.dateOfBirth != null
                  ? dateFormat.format(
                    user.dateOfBirth!.toDate(),
                  ) // Sadece formatlı tarih
                  : 'Belirtilmemiş',
              onTap: () async {
                DateTime? initialDate =
                    user.dateOfBirth?.toDate() ??
                    _selectedDateOfBirth ??
                    DateTime.now();
                if (initialDate.isBefore(DateTime(1900)))
                  initialDate = DateTime(1900);
                if (initialDate.isAfter(DateTime.now()))
                  initialDate = DateTime.now();

                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  locale: const Locale('tr', 'TR'),
                  helpText: 'DOĞUM TARİHİNİZİ SEÇİN',
                  cancelText: 'İPTAL',
                  confirmText: 'TAMAM',
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDateOfBirth = pickedDate;
                  });
                  await viewModel.updateDateOfBirth(pickedDate);
                }
              },
            ),

            // --- YENİ EKLENEN YAŞ BİLGİSİ ---
            if (user.age != null) // Sadece yaş hesaplanabildiyse göster
              _buildInfoTile(
                context,
                Icons.escalator_warning_outlined, // Yaş için uygun bir ikon
                'Yaş',
                '${user.age} yaşında',
                // Yaş düzenlenemez olduğu için onTap yok
              ),

            // --- YAŞ BİLGİSİ BİTİŞ ---
            _buildInfoTile(
              context,
              Icons.person_pin_circle_outlined,
              'Kullanıcı ID',
              user.uid,
              isSensitive: true,
            ),

            if (user.location != null)
              _buildInfoTile(
                context,
                Icons.location_on_outlined,
                'Son Bilinen Konum',
                'Enl: ${user.location!.latitude.toStringAsFixed(4)}, Boy: ${user.location!.longitude.toStringAsFixed(4)}',
              ),

            if (user.lastLocationUpdate != null)
              _buildInfoTile(
                context,
                Icons.update_outlined,
                'Son Konum Güncelleme',
                DateFormat(
                  'dd MMMM yyyy, HH:mm',
                  'tr_TR',
                ).format(user.lastLocationUpdate!.toDate()),
              ),

            if (user.createdAt != null)
              _buildInfoTile(
                context,
                Icons.cake_outlined,
                'Kayıt Tarihi',
                DateFormat(
                  'dd MMMM yyyy, HH:mm',
                  'tr_TR',
                ).format(user.createdAt!.toDate()),
              ),

            if (user.lastLogin != null)
              _buildInfoTile(
                context,
                Icons.login_outlined,
                'Son Giriş',
                DateFormat(
                  'dd MMMM yyyy, HH:mm',
                  'tr_TR',
                ).format(user.lastLogin!.toDate()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActionsCard(
    UserProfileViewModel viewModel,
    BuildContext context,
  ) {
    // Bu metodun içeriği aynı kalabilir (e-posta ve şifre değiştirme)
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Hesap İşlemleri',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            ListTile(
              leading: Icon(
                Icons.alternate_email_rounded,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: const Text('E-posta Adresini Değiştir'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                _newEmailController.clear();
                _emailPasswordController.clear();
                _showUpdateDialog(
                  context,
                  'E-posta Adresini Değiştir',
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _newEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Yeni E-posta Adresi',
                          hintText: 'ornek@mail.com',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autofocus: true,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Mevcut Şifreniz',
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                  () async => await viewModel.updateUserEmail(
                    _newEmailController.text,
                    _emailPasswordController.text,
                  ),
                  dismissibleOnSave: false,
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.lock_outline_rounded,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: const Text('Şifreyi Değiştir'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                _currentPasswordController.clear();
                _newPasswordController.clear();
                _confirmNewPasswordController.clear();
                _showUpdateDialog(
                  context,
                  'Şifreyi Değiştir',
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _currentPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Mevcut Şifre',
                        ),
                        obscureText: true,
                        autofocus: true,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _newPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Yeni Şifre',
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _confirmNewPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Yeni Şifre (Tekrar)',
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                  () async {
                    if (!mounted) return;
                    if (_newPasswordController.text !=
                        _confirmNewPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Yeni şifreler eşleşmiyor!'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    if (_newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Yeni şifre en az 6 karakter olmalıdır!',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    await viewModel.updateUserPassword(
                      _currentPasswordController.text,
                      _newPasswordController.text,
                    );
                  },
                  dismissibleOnSave: false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
    bool isSensitive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        isSensitive ? '●' * subtitle.length.clamp(8, 12) : subtitle,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
      ),
      trailing:
          onTap != null
              ? Icon(Icons.edit_outlined, size: 20, color: Colors.grey.shade600)
              : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
    );
  }
}
