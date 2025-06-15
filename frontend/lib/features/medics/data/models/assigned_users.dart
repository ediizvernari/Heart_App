class AssignedUser {
  final int    id;
  final String firstName;
  final String lastName;

  AssignedUser({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory AssignedUser.fromJson(Map<String, dynamic> json) => AssignedUser(
        id: json['id'] as int,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
      );
}