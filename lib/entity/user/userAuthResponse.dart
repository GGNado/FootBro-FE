class UserAuthResponse {
  final String token;
  final String type;
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;

  UserAuthResponse({
    required this.token,
    required this.type,
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory UserAuthResponse.fromJson(Map<String, dynamic> json) {
    return UserAuthResponse(
      token: json['token'],
      type: json['type'],
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'type': type,
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}