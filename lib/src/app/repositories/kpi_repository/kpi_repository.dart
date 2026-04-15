import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kpi/core/failure/failure.dart';
import 'package:kpi/src/api_client/client.dart';
import 'package:kpi/src/app/repositories/kpi_repository/kpi_interface.dart';
import 'package:kpi/src/models/k_task_response/k_task_response.dart';

class KpiRepository implements KpiRepositoryInterface {
  final ConcreteApiClient _apiClient;

  const KpiRepository(this._apiClient);

  @override
  ConcreteApiClient get apiClient => _apiClient;

  @override
  Future<Either<Failure, KTasksResponse>> getTasks() async {
    try {
      final formData = FormData.fromMap({
        'period_start': '2026-04-01',
        'period_end': '2026-04-30',
        'period_key': 'month',
        'requested_mo_id': 42,
        'behaviour_key': 'task,kpi_task',
        'with_result': false,
        'response_fields': 'name,indicator_to_mo_id,parent_id,order',
        'auth_user_id': 40,
      });

      final response = await apiClient.apiClient.post(
        '/get_mo_indicators',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer 5c3964b8e3ee4755f2cc0febb851e2f8',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      debugPrint('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final tasksResponse = KTasksResponse.fromJson(response.data);

        if (tasksResponse.data != null) {
          debugPrint('Получено задач: ${tasksResponse.data!.rowsCount}');
        }
        return Right(tasksResponse);
      } else {
        return Left(Failure(title: 'Ошибка: ${response.statusCode}'));
      }
    } catch (error, stackTrace) {
      debugPrint('Error: $error');
      debugPrint('StackTrace: $stackTrace');
      return Left(Failure(title: error.toString()));
    }
  }

  @override
  Future<Either<Failure, KTasksResponse>> saveOrder(
    int parentId,
    String taskName,
  ) async {
    try {
      final formData = FormData.fromMap({
        'period_start': '2025-09-01',
        'period_end': '2025-09-30',
        'period_key': 'month',
        'indicator_to_mo_id': 317886,
        'auth_user_id': 40,
        'field_name': 'parent_id',
        'field_value': '318201',
        'field_name': 'order',
        'field_value': '2',
      });

      final response = await apiClient.apiClient.post(
        '/save_indicator_instance_field',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer 5c3964b8e3ee4755f2cc0febb851e2f8',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      debugPrint('Status code: ${response.statusCode}');

      apiClient.apiClient.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );

      if (response.statusCode == 200) {
        final tasksResponse = KTasksResponse.fromJson(response.data);

        if (tasksResponse.data != null) {
          debugPrint('Сохранено задач: ${tasksResponse.data!.rowsCount}');
        }

        return Right(tasksResponse);
      } else {
        return Left(Failure(title: 'Ошибка: ${response.statusCode}'));
      }
    } catch (error, stackTrace) {
      debugPrint('Error: $error');
      debugPrint('StackTrace: $stackTrace');
      return Left(Failure(title: error.toString()));
    }
  }
}
