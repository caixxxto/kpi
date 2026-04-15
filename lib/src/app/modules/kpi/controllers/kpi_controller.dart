import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kpi/src/app/repositories/kpi_repository/kpi_interface.dart';
import 'package:kpi/src/models/k_task_response/k_task_response.dart';

import 'kpi_state.dart';

class KpiController extends Cubit<KpiState> {
  final KpiRepositoryInterface _repository;

  KpiController(this._repository) : super(const KpiState());

  Future<void> getTasks() async {
    final response = await _repository.getTasks();

    response.fold(
      (failure) {
        emit(state.copyWith(response: KTasksResponse.empty));
      },
      (tasks) {
        emit(state.copyWith(response: tasks));
      },
    );
  }

  // Future<void> saveOrder(int parentId, String taskName) async {
  //   final response = await _repository.saveOrder(parentId, taskName);
  //
  //   response.fold(
  //     (failure) {
  //
  //       //emit(state.copyWith(response:  ETasksResponse.empty));
  //     },
  //     (tasks) {
  //     },
  //   );
  // }
}
