import 'package:contatudo/app_config.dart';
import 'package:contatudo/widgets/my_main_appbar.dart';
import 'package:flutter/material.dart';

class BillingsScreen extends StatefulWidget {
  const BillingsScreen({super.key});

  @override
  State<BillingsScreen> createState() => _BillingsScreenState();
}

class _BillingsScreenState extends State<BillingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyMainAppBar(title: 'Faturação'),
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          children: [
            Text(
              'Faturação',
              style: TextStyle(fontSize: 24),
            )
          ],
        ),
      ),
    );
  }
}
