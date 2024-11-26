class Appointment {
  final String id;
  final String patientName;
  final DateTime appointmentDate;
  final String description;
  final double price;
  final String? clinicId; // ID da clínica adicionado
  final String? clinicName; // Nome da clínica
  final double? extraCost; // Custos extras
  final double? userPercentage; // Percentagem do usuário

  Appointment({
    required this.id,
    required this.patientName,
    required this.appointmentDate,
    required this.description,
    required this.price,
    this.clinicId,
    this.clinicName,
    this.extraCost,
    this.userPercentage,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'].toString(), // Converte para string caso seja numérico
      patientName: map['patient_name'] ?? '',
      appointmentDate: DateTime.parse(map['appointment_date']),
      description: map['description'] ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : map['price']?.toDouble() ?? 0.0,
      clinicId: map['clinic_id']?.toString(), // Adiciona o clinicId
      clinicName: map['clinic']?['name']?.toString(),
      extraCost: (map['extra_cost'] is int)
          ? (map['extra_cost'] as int).toDouble()
          : map['extra_cost']?.toDouble(),
      userPercentage: (map['user_percentage'] is int)
          ? (map['user_percentage'] as num).toDouble()
          : map['user_percentage']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_name': patientName,
      'appointment_date': appointmentDate.toIso8601String(),
      'description': description,
      'price': price,
      'clinic_id': clinicId,
      'clinic_name': clinicName,
      'extra_cost': extraCost,
      'user_percentage': userPercentage,
    };
  }

  double getLiquidValue() {
    print('Appointment::getLiquidValue INI');

    double liquidValue =
        (price - (extraCost ?? 0)) * (userPercentage ?? 0) / 100;
    print(
        'price: $price, extraCost: $extraCost, userPercentage: $userPercentage => finalPrice: $liquidValue');

    print('Appointment::getLiquidValue END');
    return liquidValue;
  }
}
