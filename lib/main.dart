import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kpi/src/app/modules/kpi/controllers/kpi_controller.dart';
import 'package:kpi/src/app/modules/kpi/screens/kpi_screen.dart';
import 'package:kpi/src/app/repositories/kpi_repository/kpi_interface.dart';
import 'package:provider/provider.dart';

import 'src/api_client/client.dart';
import 'src/app/modules/kpi/screens/kanban_wrapper.dart';
import 'src/app/repositories/kpi_repository/kpi_repository.dart';

void main() async {
  final apiClient = ConcreteApiClient();
  final kpiRepository = KpiRepository(apiClient);

  runApp(
    MultiProvider(
      providers: [Provider<KpiRepositoryInterface>.value(value: kpiRepository)],
      child: App(apiClient: apiClient, kpiRepository: kpiRepository),
    ),
  );
}

class App extends StatelessWidget {
  final ConcreteApiClient apiClient;
  final KpiRepositoryInterface kpiRepository;

  const App({super.key, required this.apiClient, required this.kpiRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: CustomScrollBehavior(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<KpiController>(
      create: (context) =>
          KpiController(context.read<KpiRepositoryInterface>())..getTasks(),
      child: TaskBoardWidget(),
    );
  }
}
