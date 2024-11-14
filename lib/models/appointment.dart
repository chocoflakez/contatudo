class Appointment {
  final String id;
  final String patientName;
  final DateTime appointmentDate;
  final String description;
  final double price;
  final String? clinicName; // Nome da clínica adicionado

  Appointment({
    required this.id,
    required this.patientName,
    required this.appointmentDate,
    required this.description,
    required this.price,
    this.clinicName,
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
      clinicName: map['clinic']?['name']
          ?.toString(), // Converte para string caso seja numérico
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_name': patientName,
      'appointment_date': appointmentDate.toIso8601String(),
      'description': description,
      'price': price,
      'clinic_name': clinicName,
    };
  }
}
