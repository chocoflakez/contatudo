import 'package:contatudo/app_config.dart';
import 'package:contatudo/auth_service.dart';
import 'package:contatudo/screens/billing_screen.dart';
import 'package:contatudo/screens/metrics_screen.dart';
import 'package:contatudo/widgets/my_main_appbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'appointments_screen.dart';
import 'clinics_screen.dart';
import 'package:contatudo/widgets/goal_progress_card.dart';
import 'package:contatudo/widgets/performance_indicators_card.dart';
import 'package:contatudo/widgets/my_info_card.dart';
import 'package:contatudo/widgets/my_circle_button.dart';
import 'package:contatudo/widgets/last_appointment_card.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  String userName = "";
  String userEmail = "";
  String userId = "";
  String phoneNumber = "";

  bool isLoading =
      true; // Flag to indicate if the data is being loaded from the database
  // Dashboard data
  double totalFaturadoHoje = 0.0;
  double totalFaturadoMes = 0.0;
  double totalLiquidoHoje = 0.0;
  double totalLiquidoMes = 0.0;
  int numeroConsultasHoje = 0;
  int numeroConsultasMes = 0;
  // Previous month data
  double faturamentoAnterior = 0.0;
  int consultasAnterior = 0;
  // Goal data
  double goalCurrentValue = 0.0;
  double goalTargetValue = 0.0;
  int goalTypeId = 1;
  bool hasGoal = false;
  // Last appointment data
  Map<String, dynamic>? lastAppointment;

  @override
  void initState() {
    print('DashboardScreen::initState INI');
    super.initState();

    initializeUserData();
    loadDashboardData();
    print('DashboardScreen::initState END ');
  }

  Future<void> initializeUserData() async {
    print('DashboardScreen::_initializeUserData INI');
    setState(() {
      isLoading = true;
    });

    try {
      // Certifique-se de que os detalhes do usuário são carregados no AuthService
      await AuthService.instance
          .loadUserDetails(AuthService.instance.currentUser()?.id ?? "");

      setState(() {
        userName = AuthService.instance.userName ?? "Usuário";
        userEmail = AuthService.instance.userEmail ?? "Sem email";
        userId = AuthService.instance.currentUser()?.id ?? "";
        phoneNumber = AuthService.instance.userPhone ?? "Sem telefone";
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados do utilizador: $e');
    }

    print('DashboardScreen::_initializeUserData END');
  }

  Future<void> loadDashboardData() async {
    print('DashboardScreen::loadDashboardData INI');

    // Update the state to reflect that the data is being loaded
    setState(() {
      isLoading = true;
    });

    // Update the state with the data loaded from the database
    await fetchUserGoal(); // Update the goal data in first place
    await fetchInitialData(); // Update the initial data
    await fetchLastAppointment();
    await fetchPreviousMonthData().then((previousMonthData) {
      setState(() {
        faturamentoAnterior = previousMonthData['faturamentoAnterior'];
        consultasAnterior = previousMonthData['consultasAnterior'];
      });
    });

    setState(() {
      isLoading = false;
    });

    print('DashboardScreen::loadDashboardData END');
  }

  Future<void> fetchInitialData() async {
    print('DashboardScreen::fetchInitialData INI');

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
        //Initial goal value is the total billed this month
        goalCurrentValue = totalFaturadoMes;
      });

      print('DashboardScreen::fetchInitialData END');
    } catch (error) {
      print('Erro ao buscar dados das consultas: $error');
      print('DashboardScreen::fetchInitialData END');
    }
  }

  Future<void> fetchLastAppointment() async {
    print('DashboardScreen::fetchLastAppointment INI');

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

  Future<void> fetchUserGoal() async {
    print('DashboardScreen::fetchUserGoal INI');

    try {
      final response = await supabase
          .from('user_goal')
          .select('goal_type_id, target_value')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        setState(() {
          hasGoal = true;
          goalTypeId = (response['goal_type_id'] as int);
          goalTargetValue = (response['target_value'] as num).toDouble();
        });
      } else {
        setState(() {
          hasGoal = false;
        });
      }

      print('DashboardScreen::fetchUserGoal END');
    } catch (error) {
      print('Erro ao buscar o objetivo: $error');
      print('DashboardScreen::fetchUserGoal END');
    }
  }

  Future<void> createGoal(int typeId, double targetValue) async {
    print('DashboardScreen::createGoal INI');

    try {
      await supabase.from('user_goal').insert({
        'user_id': userId,
        'goal_type_id': typeId,
        'target_value': targetValue,
      });

      // Update state to reflect the new goal
      setState(() {
        hasGoal = true;
        goalTypeId = typeId;
        goalTargetValue = targetValue;
      });

      // Update related data
      await loadDashboardData();

      print('DashboardScreen::createGoal END');
    } catch (error) {
      print('Erro ao criar objetivo: $error');
      print('DashboardScreen::createGoal END');
    }
  }

  void showCreateGoalDialog() {
    //final TextEditingController typeIdController = TextEditingController();
    final TextEditingController targetValueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Criar Objetivo",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.accentColor,
            ),
          ),
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tipo de Objetivo: Faturação',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryText,
                  )),
              const SizedBox(height: 12),
              // TextField(
              //   controller: typeIdController,
              //   decoration: const InputDecoration(
              //     labelText: "Tipo de Objetivo",
              //     hintText: "Ex: Faturamento, Consultas",
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              // const SizedBox(height: 12),
              TextFormField(
                controller: targetValueController,
                decoration: InputDecoration(
                  labelText: "Valor Alvo",
                  hintText: "1000",
                  labelStyle: const TextStyle(color: AppColors.secondaryText),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon:
                      const Icon(Icons.euro, color: AppColors.secondaryText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                        color: AppColors.accentColor, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                //final typeId = typeIdController.text;
                final targetValue =
                    double.tryParse(targetValueController.text) ?? 0.0;

                createGoal(1, targetValue);

                Navigator.pop(context);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: AppColors.accentColor, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Criar',
                    style: TextStyle(color: AppColors.accentColor),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void showEditGoalDialog() {
    final TextEditingController targetValueController =
        TextEditingController(text: goalTargetValue.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Editar Objetivo",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.accentColor,
            ),
          ),
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: TextFormField(
            controller: targetValueController,
            decoration: InputDecoration(
              labelText: "Novo Valor Alvo",
              hintText: "1000",
              labelStyle: const TextStyle(color: AppColors.secondaryText),
              filled: true,
              fillColor: Colors.white,
              prefixIcon:
                  const Icon(Icons.euro, color: AppColors.secondaryText),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide:
                    const BorderSide(color: AppColors.accentColor, width: 2),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final targetValue =
                    double.tryParse(targetValueController.text) ??
                        goalTargetValue;
                await updateGoal(targetValue);
                Navigator.pop(context);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: AppColors.accentColor, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Salvar',
                    style: TextStyle(color: AppColors.accentColor),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateGoal(double targetValue) async {
    print('DashboardScreen::updateGoal INI');

    String updatedAt = DateTime.now().toIso8601String();
    print('targetValue: $targetValue, userId: $userId, updatedAt: $updatedAt');

    try {
      await supabase.from('user_goal').update({
        'target_value': targetValue,
        'updated_at': updatedAt,
      }).eq('user_id', userId);

      setState(() {
        goalTargetValue = targetValue;
      });

      // Update related data
      await loadDashboardData();

      print('DashboardScreen::updateGoal END');
    } catch (error) {
      print('Erro ao atualizar objetivo: $error');
    }
  }

  Future<void> deleteGoal() async {
    print('DashboardScreen::deleteGoal INI');

    try {
      await supabase.from('user_goal').delete().eq('user_id', userId);

      setState(() {
        hasGoal = false;
        goalTargetValue = 0.0;
      });

      // Update related data
      await loadDashboardData();

      print('DashboardScreen::deleteGoal END');
    } catch (error) {
      print('Erro ao apagar objetivo: $error');
      print('DashboardScreen::deleteGoal END');
    }
  }

  double calcularValorLiquido(
      double price, double extraCost, int userPercentage) {
    return (price - extraCost) * (userPercentage / 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyHomeAppBar(title: 'Dashboard'),
      backgroundColor: AppColors.background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Bem-vindo, ${AuthService.instance.userName}!',
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Circular buttons for navigation
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        myCircleButton(context, 'Consultas', Icons.event_note,
                            const AppointmentsScreen()),
                        myCircleButton(context, 'Clínicas',
                            Icons.local_hospital, const ClinicsScreen()),
                        myCircleButton(context, 'Métricas', Icons.bar_chart,
                            const MetricsScreen()),
                        myCircleButton(context, 'Faturação', Icons.attach_money,
                            const BillingsScreen()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  //Card: Today and this month
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  //Card: Last appointment
                  if (lastAppointment != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          lastAppointmentCard(lastAppointment!),
                        ],
                      ),
                    ),
                  //Card: Performance indicators (comparison between current and previous month)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4),
                    child: PerformanceIndicatorsCard(
                      faturamentoAtual: totalFaturadoMes,
                      faturamentoAnterior: faturamentoAnterior,
                      consultasAtual: numeroConsultasMes,
                      consultasAnterior: consultasAnterior,
                    ),
                  ),
                  //Card: Goal progress
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4),
                    child: GoalProgressCard(
                      hasGoal: hasGoal,
                      goalCurrentValue: goalCurrentValue,
                      goalTargetValue: goalTargetValue,
                      showEditGoalDialog: showEditGoalDialog,
                      deleteGoal: deleteGoal,
                      showCreateGoalDialog: showCreateGoalDialog,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
