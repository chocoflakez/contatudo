import 'package:flutter/material.dart';

class MetricsScreen extends StatefulWidget {
  const MetricsScreen({super.key});

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Métricas'),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Métricas',
              style: TextStyle(fontSize: 24),
            )
          ],
        ),
      ),
    );
  }
}
