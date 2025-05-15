class MedicalService {
  final int id;
  final int medicId;
  final int medicalServiceTypeId;
  final String name;
  final int price;
  final int durationMinutes;

  MedicalService({
    required this.id,
    required this.medicId,
    required this.medicalServiceTypeId,
    required this.name,
    required this.price,
    required this.durationMinutes,
  });

  factory MedicalService.fromJson(Map<String, dynamic> json) => MedicalService(
    id: json['id'] as int,
    medicId: json['medic_id'] as int,
    medicalServiceTypeId: json['medical_service_type_id'] as int,
    name: json['name'] as String,
    price: json['price'] as int,
    durationMinutes: json['duration_minutes'] as int,
  );

  Map<String, dynamic> toJsonForCreate() => {
        'medical_service_type_id': medicalServiceTypeId,
        'name': name,
        'price': price.toString(),
        'duration_minutes': durationMinutes.toString(),
      };
}