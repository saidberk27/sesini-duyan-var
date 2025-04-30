class AuthService {
  Future<bool> login({required String email, required String password}) async {
    // Burada gerçek bir API isteği yapılabilir.
    // Şimdilik sahte bir doğrulama yapıyoruz.
    await Future.delayed(const Duration(seconds: 1));
    return email == 'test@test.com' && password == '123456';
  }
}
