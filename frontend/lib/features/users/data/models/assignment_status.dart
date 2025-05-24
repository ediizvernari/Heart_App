class AssignmentStatus {
  final bool isAssignedToMedic;
  final bool sharesDataWithMedic;

  AssignmentStatus({
    required this.isAssignedToMedic,
    required this.sharesDataWithMedic,
  });

  factory AssignmentStatus.fromJson(Map<String, dynamic> json) {
    return AssignmentStatus(
      isAssignedToMedic: json['has_assigned_medic'] as bool,
      sharesDataWithMedic: json['shares_data_with_medic'] as bool,
    );
  }
}