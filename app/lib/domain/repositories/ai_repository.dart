import '../../data/remote/api_client.dart';

class AiRepository {
  final ApiClient api;

  AiRepository({required this.api});

  Future<Map<String, dynamic>> getProjectSummary(String projectId) async {
    return await api.post('/api/ai/project-summary', body: {'projectId': projectId});
  }

  Future<Map<String, dynamic>> queryReport(String query, {String? projectId}) async {
    return await api.post('/api/ai/query-report', body: {
      'query': query,
      'projectId': projectId,
    });
  }

  Future<List<Map<String, dynamic>>> parseDeliveryNote(String documentText) async {
    final res = await api.post('/api/ai/parse-delivery-note', body: {
      'documentText': documentText,
    });
    return List<Map<String, dynamic>>.from(res['suggestedItems'] ?? []);
  }
}
