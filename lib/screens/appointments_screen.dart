import 'package:flutter/material.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultas'),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Consultas',
              style: TextStyle(fontSize: 24),
            )
          ],
        ),
      ),
    );
  }
}
