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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClinicsScreen()),
                );
              },
              child: Text("Ver Clínicas"),
            ),
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela de Daily work tracking
              },
              child: Text("Daily work tracking"),
            ),
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela de Consultas
              },
              child: Text("Consultas"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClinicsScreen()),
                );
              },
              child: Text("Clinicas"),
            ),
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
