class UserAuthRequest {
  final String usernameOrEmail;
  final String password;

  UserAuthRequest({
    required this.usernameOrEmail,
    required this.password,
  });

  factory UserAuthRequest.fromJson(Map<String, dynamic> json) {
    return UserAuthRequest(
      usernameOrEmail: json['usernameOrEmail'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usernameOrEmail': usernameOrEmail,
      'password': password,
    };
  }
}