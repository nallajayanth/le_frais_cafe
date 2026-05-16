import '../../models/dine_in_table.dart';
import 'api_client.dart';

class DineInService {
  final ApiClient apiClient;

  DineInService({required this.apiClient});

  Future<DineInTable> validateTableToken(String token) async {
    try {
      final response = await apiClient.post('/dinein/validate-table', {
        'token': token,
      }, requiresAuth: false);
      final payload = response['data'] as Map<String, dynamic>? ?? response;
      return DineInTable.fromJson(payload);
    } on ApiException catch (e) {
      throw DineInException(e.message);
    }
  }
}

class DineInException implements Exception {
  final String message;

  const DineInException(this.message);

  @override
  String toString() => message;
}
