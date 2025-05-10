import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/register_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/register_model.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: const _RegisterForm(),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  // _nameController yerine _firstNameController ve _lastNameController
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // Doğum tarihi ve cinsiyet için ek controller/değişkenler
  final _dateOfBirthController =
      TextEditingController(); // Tarihi göstermek için

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final viewModel = Provider.of<RegisterViewModel>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          viewModel.dateOfBirth ??
          DateTime.now().subtract(
            const Duration(days: 365 * 18),
          ), // 18 yıl öncesi
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Doğum Tarihinizi Seçin',
      cancelText: 'İptal',
      confirmText: 'Tamam',
    );
    if (picked != null && picked != viewModel.dateOfBirth) {
      setState(() {
        // UI'da tarihi göstermek için
        _dateOfBirthController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
      viewModel.dateOfBirth = picked;
    }
  }

  Future<void> _submitRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final viewModel = Provider.of<RegisterViewModel>(context, listen: false);

    // ViewModel'e yeni alanları set ediyoruz
    viewModel.firstName = _firstNameController.text;
    viewModel.lastName = _lastNameController.text;
    viewModel.email = _emailController.text;
    viewModel.password = _passwordController.text;
    viewModel.confirmPassword = _confirmPasswordController.text;
    // Doğum tarihi ve cinsiyet zaten _selectDate ve Dropdown onChanged içinde set ediliyor.

    final UserCredential? userCredential = await viewModel.register();

    if (mounted) {
      // Widget'ın hala ağaçta olup olmadığını kontrol et
      if (userCredential != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Hesabınız başarıyla oluşturuldu! Lütfen giriş yapın.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        _navigateToLogin(); // Giriş sayfasına yönlendir
      } else {
        // Hata mesajı zaten ViewModel tarafından yönetiliyor ve build metodunda gösteriliyor.
        // Burada ek bir şey yapmaya gerek yok, ViewModel'in errorMessage'i UI'da görünecektir.
      }
    }
  }

  void _navigateToLogin() {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop(); // Eğer bir önceki sayfa varsa geri dön
    } else {
      // Eğer RegisterPage doğrudan açıldıysa (önceki sayfa yoksa), login'e replace ile git
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ViewModel'i dinlemek için Consumer kullanıyoruz
    return Consumer<RegisterViewModel>(
      builder:
          (context, viewModel, child) => Scaffold(
            appBar: AppBar(
              title: const Text('Yeni Hesap Oluştur'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        // Logo yolu projenize göre güncellenmeli
                        'assets/images/logo0.png', // Eğer bu dosya yoksa hata alırsınız
                        height: 100, // Boyutu biraz küçülttüm
                      ),
                      const SizedBox(height: 24),

                      // Ad TextFormField
                      TextFormField(
                        controller: _firstNameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Adınız',
                          hintText: 'Adınızı girin',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen adınızı girin.';
                          }
                          if (value.length < 2) {
                            return 'Adınız en az 2 karakter olmalıdır.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Soyad TextFormField
                      TextFormField(
                        controller: _lastNameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Soyadınız',
                          hintText: 'Soyadınızı girin',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen soyadınızı girin.';
                          }
                          if (value.length < 2) {
                            return 'Soyadınız en az 2 karakter olmalıdır.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Doğum Tarihi TextFormField (DatePicker ile)
                      TextFormField(
                        controller: _dateOfBirthController,
                        readOnly:
                            true, // Kullanıcının doğrudan yazmasını engelle
                        decoration: InputDecoration(
                          labelText: 'Doğum Tarihi',
                          hintText: 'Doğum tarihinizi seçin',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          suffixIcon: IconButton(
                            // Tarih seçiciyi açmak için ikon
                            icon: const Icon(Icons.edit_calendar_outlined),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        onTap:
                            () =>
                                _selectDate(context), // Alana tıklayınca da aç
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen doğum tarihinizi seçin.';
                          }
                          // İsteğe bağlı: viewModel.dateOfBirth üzerinden yaş kontrolü eklenebilir
                          if (viewModel.dateOfBirth != null) {
                            final age =
                                DateTime.now().year -
                                viewModel.dateOfBirth!.year;
                            if (DateTime.now().month <
                                    viewModel.dateOfBirth!.month ||
                                (DateTime.now().month ==
                                        viewModel.dateOfBirth!.month &&
                                    DateTime.now().day <
                                        viewModel.dateOfBirth!.day)) {
                              // age--; // Bu mantık ViewModel'de var, burada sadece basit bir kontrol
                            }
                            if (age < 13) {
                              // Örnek bir yaş sınırı
                              return 'En az 13 yaşında olmalısınız.';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Cinsiyet DropdownButton
                      DropdownButtonFormField<Gender>(
                        value:
                            viewModel
                                .gender, // ViewModel'den mevcut cinsiyeti al
                        decoration: const InputDecoration(
                          labelText: 'Cinsiyet',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.wc_outlined),
                        ),
                        // Cinsiyet zorunlu değilse validator'a gerek yok,
                        // zorunluysa aşağıdaki gibi bir validator eklenebilir.
                        // validator: (value) => value == null ? 'Lütfen cinsiyetinizi seçin.' : null,
                        hint: const Text('Cinsiyetinizi seçin'),
                        isExpanded: true,
                        items:
                            Gender.values
                                .where(
                                  (gender) =>
                                      gender == Gender.male ||
                                      gender == Gender.female,
                                )
                                .map((Gender gender) {
                                  String genderText;
                                  switch (gender) {
                                    case Gender.male:
                                      genderText = 'Erkek';
                                      break;
                                    case Gender.female:
                                      genderText = 'Kadın';
                                      break;
                                    case Gender
                                        .other: // Bu case artık ulaşılamaz olmalı
                                      genderText = 'Diğer';
                                      break;
                                  }
                                  return DropdownMenuItem<Gender>(
                                    value: gender,
                                    child: Text(genderText),
                                  );
                                })
                                .toList(),
                        onChanged: (Gender? newValue) {
                          viewModel.gender =
                              newValue; // ViewModel'deki cinsiyeti güncelle
                        },
                      ),
                      const SizedBox(height: 16),

                      // E-posta TextFormField
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-posta',
                          hintText: 'ornek@eposta.com',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen e-posta adresinizi girin.';
                          }
                          final emailRegex = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Lütfen geçerli bir e-posta adresi girin.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Şifre TextFormField
                      TextFormField(
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true, // Şifreyi gizle
                        decoration: const InputDecoration(
                          labelText: 'Şifre',
                          hintText: 'Şifrenizi girin',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                          // Göz ikonu eklenebilir (obscureText'i değiştirmek için)
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen bir şifre belirleyin.';
                          }
                          if (value.length < 6) {
                            return 'Şifre en az 6 karakter olmalıdır.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Şifre Onay TextFormField
                      TextFormField(
                        controller: _confirmPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true, // Şifreyi gizle
                        decoration: const InputDecoration(
                          labelText: 'Şifreyi Onayla',
                          hintText: 'Şifrenizi tekrar girin',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen şifrenizi tekrar girin.';
                          }
                          if (value != _passwordController.text) {
                            return 'Girilen şifreler eşleşmiyor.';
                          }
                          return null;
                        },
                      ),

                      // Hata Mesajı
                      if (viewModel.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Kayıt Ol Butonu
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed:
                              viewModel.isLoading ? null : _submitRegister,
                          child:
                              viewModel.isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                  : const Text('Hesap Oluştur'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Giriş Yap Butonu
                      TextButton(
                        onPressed:
                            viewModel.isLoading ? null : _navigateToLogin,
                        child: const Text(
                          'Zaten bir hesabın var mı? Giriş Yap',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
