import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kpi/src/models/k_task_response/k_task_response.dart';

@immutable
class KpiState extends Equatable {
  final KTasksResponse? response;

  const KpiState({this.response});

  KpiState copyWith({KTasksResponse? response}) =>
      KpiState(response: response ?? this.response);

  @override
  List<Object?> get props => [response];
}
