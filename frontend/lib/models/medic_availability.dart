class MedicAvailability {
  final int id;
  final int weekday;      // 0 = Monday … 6 = Sunday
  final String startTime; // "HH:MM"
  final String endTime;   // "HH:MM"

  MedicAvailability({
    required this.id,
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });

  factory MedicAvailability.fromJson(Map<String, dynamic> json) {
    return MedicAvailability(
      id: json['id'] as int,
      weekday: json['weekday'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'weekday': weekday,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}