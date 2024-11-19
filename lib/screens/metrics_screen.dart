import 'package:contatudo/app_config.dart';
import 'package:contatudo/widgets/my_main_appbar.dart';
import 'package:contatudo/widgets/unavailable_functionality.dart';
import 'package:flutter/material.dart';

class MetricsScreen extends StatefulWidget {
  const MetricsScreen({super.key});

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyMainAppBar(title: 'Métricas'),
      backgroundColor: AppColors.background,
      body: Center(
        child: MyUnavailableFunctionality(),
      ),
    );
  }
}
