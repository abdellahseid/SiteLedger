import 'package:drift/drift.dart';
import '../../data/local/database.dart';
import '../../data/models/project_model.dart';
import '../../data/remote/api_client.dart';

class ProjectRepository {
  final ApiClient api;
  final AppDatabase db;

  ProjectRepository({required this.api, required this.db});

  Future<List<ProjectModel>> getProjects() async {
    try {
      final res = await api.get('/api/projects');
      final list = (res['projects'] as List).map((j) => ProjectModel.fromJson(j)).toList();

      for (final p in list) {
        await db.into(db.cachedProjects).insert(
          CachedProjectsCompanion.insert(
            id: p.id,
            code: p.code,
            name: p.name,
            location: p.location,
            status: Value(p.status),
            budgetEtb: Value(p.budgetEtb),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
      return list;
    } catch (_) {
      final rows = await db.select(db.cachedProjects).get();
      return rows.map((r) => ProjectModel(
        id: r.id,
        code: r.code,
        name: r.name,
        location: r.location,
        status: r.status,
        budgetEtb: r.budgetEtb,
      )).toList();
    }
  }

  Future<Map<String, dynamic>> getProjectDetails(String id) async {
    final res = await api.get('/api/projects/$id');
    return {
      'project': ProjectModel.fromJson(res['project']),
      'materialSummary': res['materialSummary'] as List? ?? [],
    };
  }
}
