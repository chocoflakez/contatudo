import 'package:contatudo/app_config.dart';
import 'package:contatudo/screens/billing_screen.dart';
import 'package:contatudo/screens/metrics_screen.dart';
import 'package:contatudo/widgets/my_main_appbar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'appointments_screen.dart';
import 'clinics_screen.dart';

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

  @override
  void initState() {
    super.initState();
    fetchClinicDataForPieChart();
  }

  Future<void> fetchClinicDataForPieChart() async {
    print('DashboardScreen::fetchClinicDataForPieChart INI');
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

      print(
          'Consultando dados de ${inicioDoMes.toIso8601String()} até ${hoje.toIso8601String()} para o usuário $userId');

      final response = await supabase
          .from('appointment')
          .select(
              'clinic_id, price, extra_cost, user_percentage, appointment_date, clinic (id, name)')
          .eq('user_id', userId)
          .gte('appointment_date', inicioDoMes.toIso8601String())
          .lte('appointment_date', hoje.toIso8601String());

      if (response == null || response.isEmpty) {
        print('Resposta vazia. Nenhum dado encontrado.');
        return;
      }

      print('Dados recebidos: ${response.length} registros encontrados');

      final clinicTotals = <String, double>{};
      double totalHoje = 0.0;
      double totalMes = 0.0;
      double liquidoHoje = 0.0;
      double liquidoMes = 0.0;
      int consultasHoje = 0;
      int consultasMes = 0;

      for (var appointment in response) {
        final clinic = appointment['clinic'] as Map<String, dynamic>?;
        final clinicName = clinic?['name'] as String? ?? 'Desconhecida';
        final price = (appointment['price'] as num).toDouble();
        final extraCost =
            (appointment['extra_cost'] as num?)?.toDouble() ?? 0.0;
        final userPercentage = appointment['user_percentage'] as int? ?? 100;
        final appointmentDate = DateTime.parse(appointment['appointment_date']);

        print(
            'Processando consulta: Clínica: $clinicName, Preço: $price€, Custos Extras: $extraCost€, Percentual: $userPercentage%, Data: $appointmentDate');

        final valorLiquido =
            calcularValorLiquido(price, extraCost, userPercentage);

        // Atualiza o total do mês e o número de consultas
        totalMes += price;
        liquidoMes += valorLiquido;
        consultasMes++;

        // Atualiza o total de hoje se a data for igual ao dia atual
        if (appointmentDate.year == hoje.year &&
            appointmentDate.month == hoje.month &&
            appointmentDate.day == hoje.day) {
          totalHoje += price;
          liquidoHoje += valorLiquido;
          consultasHoje++;
          print(
              'Consulta de hoje adicionada: $price€ (Líquido: $valorLiquido€)');
        }

        // Atualiza os totais por clínica
        if (clinicTotals.containsKey(clinicName)) {
          clinicTotals[clinicName] = clinicTotals[clinicName]! + price;
        } else {
          clinicTotals[clinicName] = price;
        }
      }

      print('Total faturado hoje: ${totalHoje.toStringAsFixed(2)}€');
      print('Total faturado no mês: ${totalMes.toStringAsFixed(2)}€');
      print('Total líquido hoje: ${liquidoHoje.toStringAsFixed(2)}€');
      print('Total líquido no mês: ${liquidoMes.toStringAsFixed(2)}€');
      print('Número de consultas hoje: $consultasHoje');
      print('Número de consultas no mês: $consultasMes');

      setState(() {
        totalFaturadoHoje = totalHoje;
        totalFaturadoMes = totalMes;
        totalLiquidoHoje = liquidoHoje;
        totalLiquidoMes = liquidoMes;
        numeroConsultasHoje = consultasHoje;
        numeroConsultasMes = consultasMes;

        sections = clinicTotals.entries.map((entry) {
          return PieChartSectionData(
            value: entry.value,
            title: '${entry.value.toStringAsFixed(2)}€',
            color: Colors
                .primaries[entry.key.hashCode % Colors.primaries.length]
                .withOpacity(0.85),
            radius: 50,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          );
        }).toList();
      });

      print('DashboardScreen::fetchClinicDataForPieChart END');
    } catch (error) {
      print('Erro ao buscar dados das consultas: $error');
    }
  }

  double calcularValorLiquido(
      double price, double extraCost, int userPercentage) {
    final valorLiquido = (price - extraCost) * (userPercentage / 100);
    print(
        'Calculando valor líquido: Preço: $price€, Custos Extras: $extraCost€, Percentual: $userPercentage%, Resultado: ${valorLiquido.toStringAsFixed(2)}€');
    return valorLiquido;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyMainAppBar(title: 'Dashboard'),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botões circulares (Consultas, Clínicas e Faturação)
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
            // Gráfico de pizza com dados reais e estilizados
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 300,
                child: sections.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : PieChart(
                        PieChartData(
                          sections: sections,
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
              ),
            ),
            // Cartões com informações sobre as consultas
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  myInfoCard(
                    'Hoje',
                    'Consultas: $numeroConsultasHoje\n'
                        'Total: ${totalFaturadoHoje.toStringAsFixed(2)}€\n'
                        'Líquido: ${totalLiquidoHoje.toStringAsFixed(2)}€',
                  ),
                  const SizedBox(width: 16),
                  myInfoCard(
                    'Este Mês',
                    'Consultas: $numeroConsultasMes\n'
                        'Total: ${totalFaturadoMes.toStringAsFixed(2)}€\n'
                        'Líquido: ${totalLiquidoMes.toStringAsFixed(2)}€',
                  ),
                ],
              ),
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
              color: Colors.blueAccent
                  .withOpacity(0.1), // Fundo azul claro com transparência
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.blueAccent, // Cor da borda azul
                width: 2, // Largura da borda
              ),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor:
                  Colors.transparent, // Define o fundo como transparente
              child: Icon(icon, size: 30, color: Colors.blueAccent),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppColors
                .accentColor, // Usa a cor de destaque definida no AppConfig
          ),
        ),
      ],
    );
  }

  Widget myInfoCard(String title, String content) {
    return Expanded(
      child: Material(
        elevation: 4, // Aplica a elevação desejada
        color: Colors
            .transparent, // Evita que a cor de fundo do Material afete o Container
        shadowColor: Colors.black.withOpacity(0.2), // Controla a sombra
        borderRadius: BorderRadius.circular(16.0), // Arredonda as bordas
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor, // Garante que a cor seja branca
            borderRadius:
                BorderRadius.circular(16.0), // Mesma borda do Material
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: TextStyle(
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
}
