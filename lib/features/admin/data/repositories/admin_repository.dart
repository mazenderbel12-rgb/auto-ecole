import '../datasources/admin_remote_data_source.dart';

class AdminRepository {
  final AdminRemoteDataSource _dataSource;

  AdminRepository(this._dataSource);

  Future<Map<String, dynamic>> getDashboardStats() async {
    return await _dataSource.getDashboardStats();
  }

  Future<List<dynamic>> getUsers(String role) async {
    return await _dataSource.getUsers(role);
  }

  Future<void> deleteUser(String userId) async {
    await _dataSource.deleteUser(userId);
  }

  // --- Admin Service Operations ---

  Future<void> createCandidat(Map<String, dynamic> data) async {
    await _dataSource.createCandidat(data);
  }

  Future<void> createMoniteur(Map<String, dynamic> data) async {
    await _dataSource.createMoniteur(data);
  }

  Future<void> createSeance(Map<String, dynamic> data) async {
    await _dataSource.createSeance(data);
  }

  Future<void> createPaiement(Map<String, dynamic> data) async {
    await _dataSource.createPaiement(data);
  }

  Future<List<dynamic>> getPersonnel() async {
    return await _dataSource.getPersonnel();
  }

  Future<List<dynamic>> getVehicules() async {
    return await _dataSource.getVehicules();
  }
}
