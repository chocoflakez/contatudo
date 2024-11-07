import 'package:flutter/material.dart';
import 'clinic_detail_screen.dart';

class ClinicsScreen extends StatefulWidget {
  const ClinicsScreen({super.key});

  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

class _ClinicsScreenState extends State<ClinicsScreen> {
  final List<String> clinics = [
    'Clínica São Paulo',
    'Clínica Rio de Janeiro',
    'Clínica Minas Gerais',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clínicas'),
      ),
      body: ListView.builder(
        itemCount: clinics.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(clinics[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ClinicDetailScreen(clinicName: clinics[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
