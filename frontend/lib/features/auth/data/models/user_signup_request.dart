class UserSignupRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  UserSignupRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
      };
}
