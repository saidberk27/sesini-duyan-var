enum Gender { male, female, other }

class RegisterModel {
  final String email;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final Gender gender;
  final String?
  displayName; // İsteğe bağlı, belki firstName + lastName'den oluşturulur

  RegisterModel({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.displayName,
  });

  bool get passwordsMatch => password == confirmPassword;

  String get genderToString {
    switch (gender) {
      case Gender.male:
        return 'male';
      case Gender.female:
        return 'female';
      case Gender.other:
        return 'other';
    }
  }
}
