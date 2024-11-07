import 'package:flutter/material.dart';

class ClinicDetailScreen extends StatelessWidget {
  final String clinicName;

  ClinicDetailScreen({required this.clinicName});

  @override
  Widget build(BuildContext context) {
    // Exemplo de dados simulados de pacientes
    final List<Map<String, dynamic>> patientStats = [
      {'name': 'Paciente 1', 'consultas': 5, 'ultimaConsulta': '10/10/2023'},
      {'name': 'Paciente 2', 'consultas': 3, 'ultimaConsulta': '05/09/2023'},
      {'name': 'Paciente 3', 'consultas': 7, 'ultimaConsulta': '20/08/2023'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Estatísticas - $clinicName"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Estatísticas dos Pacientes",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: patientStats.length,
                itemBuilder: (context, index) {
                  final patient = patientStats[index];
                  return Card(
                    child: ListTile(
                      title: Text(patient['name']),
                      subtitle: Text(
                          "Consultas: ${patient['consultas']}\nÚltima Consulta: ${patient['ultimaConsulta']}"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
