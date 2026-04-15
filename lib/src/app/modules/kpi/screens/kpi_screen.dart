import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kpi/src/app/modules/kpi/controllers/kpi_controller.dart'
    show KpiController;
import 'package:kpi/src/app/modules/kpi/controllers/kpi_state.dart';
import 'package:kpi/src/app/modules/kpi/screens/kanban_board.dart';

class TaskBoardWidget extends StatefulWidget {
  const TaskBoardWidget({super.key});

  @override
  _TaskBoardWidgetState createState() => _TaskBoardWidgetState();
}

class _TaskBoardWidgetState extends State<TaskBoardWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KpiController, KpiState>(
      builder: (context, state) {
        return Scaffold(
          body:
              state.response != null &&
                  state.response!.data != null &&
                  state.response!.data!.rows != null
              ? KanbanBoard(tasks: state.response!.data!.rows!)
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
