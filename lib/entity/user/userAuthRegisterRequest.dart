

class UserAuthRegisterRequest {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final List<String> roles;
  final List<String> ruoliPreferiti;

  UserAuthRegisterRequest({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.roles,
    required this.ruoliPreferiti,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'roles': roles,
      'ruoliPreferiti': ruoliPreferiti,
    };
  }
}