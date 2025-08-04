class UserCampionatoResponse{
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;

  UserCampionatoResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory UserCampionatoResponse.fromJson(Map<String, dynamic> json) {
    return UserCampionatoResponse(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
}