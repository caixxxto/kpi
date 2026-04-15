import 'package:dartz/dartz.dart';
import 'package:kpi/src/models/k_task_response/k_task_response.dart';
import '../../../../core/failure/failure.dart';
import '../../../api_client/client.dart';

abstract interface class KpiRepositoryInterface {
  ConcreteApiClient get apiClient;

  Future<Either<Failure, KTasksResponse>> getTasks();

  Future<Either<Failure, KTasksResponse>> saveOrder(
    int parentId,
    String taskName,
  );
}
