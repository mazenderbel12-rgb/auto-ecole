import '../datasources/user_remote_data_source.dart';
import '../models/admin_user_model.dart';

class UserService {
  final UserRemoteDataSource _remote;

  UserService(this._remote);

  Future<PagedUsers> fetchAllUsers({
    required String role,
    required int page,
    String? query,
  }) async {
    final response = await _remote.fetchUsers(role: role, page: page, query: query);
    final users = response.items
        .whereType<Map>()
        .map((item) => AdminUser.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    return PagedUsers(users: users, currentPage: response.currentPage, lastPage: response.lastPage);
  }

  Future<AdminUser> createUser(AdminUser user) async {
    final payload = Map<String, dynamic>.from(user.toJson());
    payload.remove('Id_Utilisateur');
    final data = await _remote.createUser(payload);
    return AdminUser.fromJson(data);
  }

  Future<AdminUser> updateUser(AdminUser user) async {
    final data = await _remote.updateUser(user.id, user.toJson());
    return AdminUser.fromJson(data);
  }

  Future<void> deleteUser(String id) async {
    await _remote.deleteUser(id);
  }
}

class PagedUsers {
  final List<AdminUser> users;
  final int currentPage;
  final int lastPage;

  const PagedUsers({
    required this.users,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;
}
