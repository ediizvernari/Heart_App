class AssignedUser {
  final int    id;
  final String firstName;
  final String lastName;
  final bool   sharesDataWithMedic;

  AssignedUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.sharesDataWithMedic,
  });

  factory AssignedUser.fromJson(Map<String, dynamic> json) => AssignedUser(
        id: json['id'] as int,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        sharesDataWithMedic: json['shares_data_with_medic'] as bool,
      );
}