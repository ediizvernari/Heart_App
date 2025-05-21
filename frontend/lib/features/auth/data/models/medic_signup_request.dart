class MedicSignupRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String streetAddress;
  final String city;
  final String country;

  MedicSignupRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.streetAddress,
    required this.city,
    required this.country,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'street_address': streetAddress,
        'city': city,
        'country': country,
      };
}