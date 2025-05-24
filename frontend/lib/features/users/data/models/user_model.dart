class User {
  final int id;
  final String firstName;
  final String lastName;
  final bool sharesDataWithMedic;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.sharesDataWithMedic,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      sharesDataWithMedic: json['shares_data_with_medic'] as bool,
    );
  }
}