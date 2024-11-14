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
      id: map['id'].toString(), // Converte o ID para String, se necessário
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      userId: map['user_id']
          .toString(), // Converte o userId para String, se necessário
      defaultPayValue: (map['default_pay_value'] ?? 0).toDouble(),
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
