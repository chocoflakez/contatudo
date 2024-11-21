import 'package:contatudo/app_config.dart';
import 'package:contatudo/screens/billing_screen.dart';
import 'package:contatudo/screens/metrics_screen.dart';
import 'package:contatudo/widgets/my_main_appbar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'appointments_screen.dart';
import 'clinics_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<PieChartSectionData> sections = [];
  double totalFaturadoHoje = 0.0;
  double totalFaturadoMes = 0.0;
  double totalLiquidoHoje = 0.0;
  double totalLiquidoMes = 0.0;
  int numeroConsultasHoje = 0;
  int numeroConsultasMes = 0;
  double faturamentoAnterior = 0.0;
  int consultasAnterior = 0;
  Map<String, dynamic>? lastAppointment;

  @override
  void initState() {
    super.initState();
    fetchInitialData(); // Busca dados gerais
    fetchLastAppointment(); // Busca a última consulta separadamente
    fetchPreviousMonthData().then((previousMonthData) {
      setState(() {
        faturamentoAnterior = previousMonthData['faturamentoAnterior'];
        consultasAnterior = previousMonthData['consultasAnterior'];
      });
    });
  }

  Future<void> fetchInitialData() async {
    print('DashboardScreen::fetchInitialData INI');
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      print('Usuário não autenticado.');
      return;
    }

    try {
      final inicioDoMes =
          DateTime(DateTime.now().year, DateTime.now().month, 1);
      final hoje = DateTime.now();

      final response = await supabase
          .from('appointment')
          .select(
              'clinic_id, price, extra_cost, user_percentage, appointment_date, clinic (id, name)')
          .eq('user_id', userId)
          .gte('appointment_date', inicioDoMes.toIso8601String())
          .lte('appointment_date', hoje.toIso8601String());

      if (response.isEmpty) return;

      double totalHoje = 0.0,
          totalMes = 0.0,
          liquidoHoje = 0.0,
          liquidoMes = 0.0;
      int consultasHoje = 0, consultasMes = 0;

      for (var appointment in response) {
        final price = (appointment['price'] as num).toDouble();
        final extraCost =
            (appointment['extra_cost'] as num?)?.toDouble() ?? 0.0;
        final userPercentage = appointment['user_percentage'] as int? ?? 100;
        final appointmentDate = DateTime.parse(appointment['appointment_date']);

        final valorLiquido =
            calcularValorLiquido(price, extraCost, userPercentage);

        totalMes += price;
        liquidoMes += valorLiquido;
        consultasMes++;

        if (appointmentDate.year == hoje.year &&
            appointmentDate.month == hoje.month &&
            appointmentDate.day == hoje.day) {
          totalHoje += price;
          liquidoHoje += valorLiquido;
          consultasHoje++;
        }
      }

      setState(() {
        totalFaturadoHoje = totalHoje;
        totalFaturadoMes = totalMes;
        totalLiquidoHoje = liquidoHoje;
        totalLiquidoMes = liquidoMes;
        numeroConsultasHoje = consultasHoje;
        numeroConsultasMes = consultasMes;
      });

      print('DashboardScreen::fetchInitialData END');
    } catch (error) {
      print('Erro ao buscar dados das consultas: $error');
      print('DashboardScreen::fetchInitialData END');
    }
  }

  Future<void> fetchLastAppointment() async {
    print('DashboardScreen::fetchLastAppointment INI');
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    try {
      final response = await supabase
          .from('appointment')
          .select(
              'patient_name, clinic (name), appointment_date, price, extra_cost, user_percentage')
          .eq('user_id', userId)
          .order('appointment_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return;

      setState(() {
        lastAppointment = response;
      });
      print('DashboardScreen::fetchLastAppointment END');
    } catch (error) {
      print('Erro ao buscar última consulta: $error');
      print('DashboardScreen::fetchLastAppointment END');
    }
  }

  Future<Map<String, dynamic>> fetchPreviousMonthData() async {
    print('DashboardScreen::fetchPreviousMonthData INI');
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      print('Usuário não autenticado.');
      return {'faturamentoAnterior': 0.0, 'consultasAnterior': 0};
    }

    try {
      final now = DateTime.now();
      final firstDayOfPreviousMonth = DateTime(now.year, now.month - 1, 1);
      final lastDayOfPreviousMonth = DateTime(now.year, now.month, 0);

      print(
          'Consultando dados de ${firstDayOfPreviousMonth.toIso8601String()} até ${lastDayOfPreviousMonth.toIso8601String()} para o usuário $userId');

      final response = await supabase
          .from('appointment')
          .select('price, extra_cost, user_percentage')
          .eq('user_id', userId)
          .gte('appointment_date', firstDayOfPreviousMonth.toIso8601String())
          .lte('appointment_date', lastDayOfPreviousMonth.toIso8601String());

      if (response.isEmpty) {
        print('Nenhum dado encontrado para o mês anterior.');
        return {'faturamentoAnterior': 0.0, 'consultasAnterior': 0};
      }

      double faturamentoAnterior = 0.0;
      int consultasAnterior = 0;

      for (var appointment in response) {
        final price = (appointment['price'] as num).toDouble();
        faturamentoAnterior += price;
        consultasAnterior++;
      }

      print('Faturamento Anterior: $faturamentoAnterior');
      print('Consultas Anteriores: $consultasAnterior');
      print('DashboardScreen::fetchPreviousMonthData END');

      return {
        'faturamentoAnterior': faturamentoAnterior,
        'consultasAnterior': consultasAnterior,
      };
    } catch (error) {
      print('Erro ao buscar dados do mês anterior: $error');
      print('DashboardScreen::fetchPreviousMonthData END');
      return {'faturamentoAnterior': 0.0, 'consultasAnterior': 0};
    }
  }

  double calcularValorLiquido(
      double price, double extraCost, int userPercentage) {
    return (price - extraCost) * (userPercentage / 100);
  }

  Widget lastAppointmentCard(Map<String, dynamic> consulta) {
    final patientName = consulta['patient_name'] ?? 'N/A';
    final clinicName = consulta['clinic']['name'] ?? 'N/A';
    final appointmentDate =
        DateTime.parse(consulta['appointment_date']).toLocal();
    final price = (consulta['price'] as num).toDouble();
    final extraCost = (consulta['extra_cost'] as num?)?.toDouble() ?? 0.0;
    final userPercentage = consulta['user_percentage'] as int? ?? 100;
    final valorLiquido = calcularValorLiquido(price, extraCost, userPercentage);

    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.accentColor.withOpacity(0.1),
              child: const Icon(Icons.event_note, color: AppColors.accentColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última consulta',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentColor,
                    ),
                    softWrap: false,
                  ),
                  Text(
                    patientName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Text(
                    clinicName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  Text(
                    DateFormat('dd-MM-yyyy').format(appointmentDate),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${price.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                Text(
                  '${valorLiquido.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget myCircleButton(
      BuildContext context, String label, IconData icon, Widget targetScreen) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetScreen),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentColor, width: 1.5),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.transparent,
              child: Icon(icon, size: 30, color: AppColors.accentColor),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.accentColor,
          ),
        ),
      ],
    );
  }

  Widget myInfoCard(String title, String content) {
    return Expanded(
      child: Material(
        elevation: 4,
        color: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget performanceIndicatorsCard(double faturamentoAtual,
      double faturamentoAnterior, int consultasAtual, int consultasAnterior) {
    final faturamentoVariacao = faturamentoAnterior != 0
        ? ((faturamentoAtual - faturamentoAnterior) / faturamentoAnterior) * 100
        : 100;
    final consultasVariacao = consultasAnterior != 0
        ? consultasAtual - consultasAnterior
        : consultasAtual;

    final faturamentoIcon =
        faturamentoVariacao >= 0 ? Icons.arrow_upward : Icons.arrow_downward;
    final consultasIcon =
        consultasVariacao >= 0 ? Icons.arrow_upward : Icons.arrow_downward;

    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.accentColor.withOpacity(0.1),
              child: const Icon(Icons.insights, color: AppColors.accentColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        "Indicadores de Performance",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Tooltip(
                        message:
                            "Comparação entre o mês atual e o mês anterior.",
                        child: Icon(Icons.info_outline,
                            size: 18, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(faturamentoIcon,
                          color: faturamentoVariacao >= 0
                              ? Colors.green
                              : Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        "Faturação: ${faturamentoVariacao.toStringAsFixed(2)} %",
                        style: TextStyle(
                          fontSize: 14,
                          color: faturamentoVariacao >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(consultasIcon,
                          color: consultasVariacao >= 0
                              ? Colors.green
                              : Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        "Consultas: ${consultasVariacao >= 0 ? '+ ' : ''}$consultasVariacao",
                        style: TextStyle(
                          fontSize: 14,
                          color: consultasVariacao >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyHomeAppBar(title: 'Dashboard'),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botões circulares
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  myCircleButton(context, 'Consultas', Icons.event_note,
                      const AppointmentsScreen()),
                  myCircleButton(context, 'Clínicas', Icons.local_hospital,
                      const ClinicsScreen()),
                  myCircleButton(context, 'Métricas', Icons.bar_chart,
                      const MetricsScreen()),
                  myCircleButton(context, 'Faturação', Icons.attach_money,
                      const BillingsScreen()),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Cartões de informações
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Resumo:',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  myInfoCard(
                    'Hoje',
                    'Consultas: $numeroConsultasHoje\n'
                        'Total: ${totalFaturadoHoje.toStringAsFixed(2)} €\n'
                        'Líquido: ${totalLiquidoHoje.toStringAsFixed(2)} €',
                  ),
                  const SizedBox(width: 16),
                  myInfoCard(
                    'Este Mês',
                    'Consultas: $numeroConsultasMes\n'
                        'Total: ${totalFaturadoMes.toStringAsFixed(2)} €\n'
                        'Líquido: ${totalLiquidoMes.toStringAsFixed(2)} €',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Última consulta
            if (lastAppointment != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    lastAppointmentCard(lastAppointment!),
                  ],
                ),
              ),
            //Comparação meses
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: performanceIndicatorsCard(
                totalFaturadoMes,
                faturamentoAnterior,
                numeroConsultasMes,
                consultasAnterior,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
