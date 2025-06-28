class AppointmentRequest {
  final int medicId;
  final int medicalServiceId;
  final String address;
  final DateTime appointmentStart;
  final DateTime appointmentEnd;

  AppointmentRequest({
    required this.medicId,
    required this.medicalServiceId,
    required this.address,
    required this.appointmentStart,
    required this.appointmentEnd,
  });

  Map<String, dynamic> toJson() => {
    'medic_id': medicId,
    'medical_service_id': medicalServiceId,
    'address': address,
    'appointment_start': appointmentStart.toIso8601String(),
    'appointment_end': appointmentEnd.toIso8601String(),
  };
}
