import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_view_model.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const _LoginForm(),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = Provider.of<LoginViewModel>(context, listen: false);
      viewModel.email = _emailController.text;
      viewModel.password = _passwordController.text;

      final result = await viewModel.login();

      if (result != null && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
      // Hata durumu viewModel'in errorMessage'ında tutulacak ve
      // otomatik olarak gösterilecek
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder:
          (context, viewModel, child) => Scaffold(
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo0.png', // Logo path'ini kendi projenize göre güncelleyin
                        height: 180,
                        width: 180,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-posta',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'E-posta giriniz';
                          }
                          if (!value.contains('@')) {
                            return 'Geçerli bir e-posta giriniz';
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
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Şifre giriniz';
                          }
                          if (value.length < 6) {
                            return 'Şifre en az 6 karakter olmalı';
                          }
                          return null;
                        },
                      ),
                      if (viewModel.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading ? null : _login,
                          child:
                              viewModel.isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text('Giriş Yap'),
                        ),
                      ),
                      const SizedBox(height: 16), // Butonlar arası boşluk
                      // Kaydol Butonu
                      TextButton(
                        onPressed:
                            viewModel.isLoading ? null : _navigateToRegister,
                        child: const Text(
                          'Hesabın yok mu? Kaydol',
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
