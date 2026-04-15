import 'package:dio/dio.dart';

const apiKey = '5c3964b8e3ee4755f2cc0febb851e2f8';

class ConcreteApiClient {
  late final Dio apiClient;
  final String bearerToken = '5c3964b8e3ee4755f2cc0febb851e2f8';

  ConcreteApiClient() {
    _setupApiClient();
  }

  void _setupApiClient() {
    apiClient = Dio(
      BaseOptions(
        baseUrl: 'https://api.dev.kpi-drive.ru/_api/indicators',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }
}
