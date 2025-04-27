class Medic {
  final int id;
  final String  firstName;
  final String lastName;
  final String email;
  final String streetAddress;
  final String city;
  final String country;

  Medic({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.streetAddress,
    required this.city,
    required this.country,
  });

  factory Medic.fromJson(Map<String, dynamic> json) {
    return Medic(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      streetAddress: json['street_address'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
    );
  }
}
