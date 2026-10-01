import '../../data/models/user_model.dart';
import '../../data/remote/api_client.dart';

class AuthRepository {
  final ApiClient api;

  AuthRepository({required this.api});

  Future<UserProfile> login(String email, String password) async {
    final res = await api.post('/api/auth/login', body: {
      'email': email,
      'password': password,
    });

    final token = res['token'];
    api.setToken(token);

    return UserProfile.fromJson(res['user'], res['organization']);
  }

  Future<List<Map<String, dynamic>>> getDemoAccounts() async {
    final res = await api.get('/api/auth/demo-accounts');
    return List<Map<String, dynamic>>.from(res['accounts']);
  }
}
