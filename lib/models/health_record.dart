class HealthRecord {
  final int? id;
  final String date;
  final double weight;
  final double height;
  final String bloodPressure;
  final int heartRate;
  final String notes;

  const HealthRecord({
    this.id,
    required this.date,
    required this.weight,
    required this.height,
    required this.bloodPressure,
    required this.heartRate,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'weight': weight,
      'height': height,
      'bloodPressure': bloodPressure,
      'heartRate': heartRate,
      'notes': notes,
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      bloodPressure: map['bloodPressure'] as String,
      heartRate: map['heartRate'] as int,
      notes: (map['notes'] as String?) ?? '',
    );
  }

  HealthRecord copyWith({
    int? id,
    String? date,
    double? weight,
    double? height,
    String? bloodPressure,
    int? heartRate,
    String? notes,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      heartRate: heartRate ?? this.heartRate,
      notes: notes ?? this.notes,
    );
  }
}
