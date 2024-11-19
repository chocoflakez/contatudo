class Clinic {
  final String id;
  final String name;
  final String location;
  final String userId;
  final double defaultPayValue;

  Clinic({
    required this.id,
    required this.name,
    required this.location,
    required this.userId,
    required this.defaultPayValue,
  });

  // Método para criar um objeto `Clinic` a partir de um Map
  factory Clinic.fromMap(Map<String, dynamic> map) {
    return Clinic(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      userId: map['user_id'].toString(),
      defaultPayValue: (map['default_pay_value'] is int)
          ? (map['default_pay_value'] as int).toDouble()
          : map['default_pay_value']?.toDouble() ?? 0.0,
    );
  }

  // Método para converter o objeto `Clinic` em um Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'user_id': userId,
      'default_pay_value': defaultPayValue,
    };
  }
}
