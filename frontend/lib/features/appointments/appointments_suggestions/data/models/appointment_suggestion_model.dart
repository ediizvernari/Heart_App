class AppointmentSuggestion {
  final int id;
  final int userId;
  final int medicId;
  final int medicalServiceId;
  final String status;
  final String reason;
  final DateTime createdAt;

  AppointmentSuggestion({
    required this.id,
    required this.userId,
    required this.medicId,
    required this.medicalServiceId,
    required this.status,
    required this.reason,
    required this.createdAt,
  });

  factory AppointmentSuggestion.fromJson(Map<String, dynamic> json) =>
      AppointmentSuggestion(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        medicId: json['medic_id'] as int,
        medicalServiceId: json['medical_service_id'] as int,
        status: json['status'] as String,
        reason: json['reason'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJsonForCreate() => {
        'medical_service_id': medicalServiceId,
        'reason': reason,
      };
}