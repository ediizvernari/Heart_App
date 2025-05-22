class MedicalServiceType{
  final int id;
  final String name;

  MedicalServiceType({required this.id, required this.name});

  factory MedicalServiceType.fromJson(Map<String, dynamic> json) => MedicalServiceType(
    id: json['id'] as int,
    name: json['name'] as String,
    );
}