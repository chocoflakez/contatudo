import 'package:contatudo/screens/appointments_screen.dart';
import 'package:flutter/material.dart';
import 'clinics_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela de Daily work tracking
              },
              child: Text("Daily work tracking"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppointmentsScreen()),
                );
              },
              child: Text("Consultas"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClinicsScreen()),
                );
              },
              child: Text("Clinicas"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela de Metricas
              },
              child: Text("Metricas"),
            ),
          ],
        ),
      ),
    );
  }
}
