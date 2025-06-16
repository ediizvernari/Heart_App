class AssignmentStatus {
  final bool isAssignedToMedic;

  AssignmentStatus({
    required this.isAssignedToMedic,
  });

  factory AssignmentStatus.fromJson(Map<String, dynamic> json) {
    return AssignmentStatus(
      isAssignedToMedic: json['has_assigned_medic'] as bool,
    );
  }
}