class Appointment {
  final int id;
  final int userId;
  final int medicId;
  final int medicalServiceId;
  final String address;
  final String medicalServiceName;
  final int medicalServicePrice;
  final int medicalServiceDurationMinutes;
  final DateTime appointmentStart;
  final DateTime appointmentEnd;
  final String appointmentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.medicId,
    required this.medicalServiceId,
    required this.address,
    required this.medicalServiceName,
    required this.medicalServicePrice,
    required this.medicalServiceDurationMinutes,
    required this.appointmentStart,
    required this.appointmentEnd,
    required this.appointmentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        medicId: json['medic_id'] as int,
        medicalServiceId: json['medical_service_id'] as int,
        address: json['address'] as String,
        medicalServiceName: json['medical_service_name'] as String,
        medicalServicePrice: json['medical_service_price'] as int,
        medicalServiceDurationMinutes: json['medical_service_duration_minutes'] as int,
        appointmentStart: DateTime.parse(json['appointment_start'] as String),
        appointmentEnd: DateTime.parse(json['appointment_end'] as String),
        appointmentStatus: json['appointment_status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJsonForCreate() {
    return {
      'medical_service_id': medicalServiceId,
      'medic_id': medicId,
      'address': address,
      'appointment_start': appointmentStart.toIso8601String(),
      'appointment_end': appointmentEnd.toIso8601String(),
    };
  }
}
