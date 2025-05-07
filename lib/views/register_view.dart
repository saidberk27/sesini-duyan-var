import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/register_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final viewModel = Provider.of<RegisterViewModel>(context, listen: false);

    viewModel.name = _nameController.text;
    viewModel.email = _emailController.text;
    viewModel.password = _passwordController.text;
    viewModel.confirmPassword = _confirmPasswordController.text;

    final UserCredential? userCredential = await viewModel.register();

    if (mounted) {
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

        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {}
    }
  }

  void _navigateToLogin() {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        'assets/images/logo0.png',
                        height: 150,
                        width: 150,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Ad Soyad',
                          hintText: 'Adınız ve soyadınız',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen adınızı ve soyadınızı girin.';
                          }
                          if (value.length < 3) {
                            return 'Ad soyad en az 3 karakter olmalıdır.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                      TextFormField(
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Şifre',
                          hintText: 'Şifrenizi girin',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
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
                      TextFormField(
                        controller: _confirmPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
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
