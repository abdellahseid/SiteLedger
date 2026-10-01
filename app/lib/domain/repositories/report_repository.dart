import '../../data/remote/api_client.dart';

class ReportRepository {
  final ApiClient api;

  ReportRepository({required this.api});

  Future<Map<String, dynamic>> getDashboardMetrics({String? projectId}) async {
    final queryParams = <String, String>{};
    if (projectId != null) queryParams['projectId'] = projectId;

    return await api.get('/api/reports/dashboard', queryParams: queryParams);
  }

  Future<String> exportCsv() async {
    final res = await api.get('/api/reports/export-csv');
    return res.toString();
  }
}
