import 'package:dio/dio.dart';
import '../../../../core/utils/token_manager.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepository(this._dataSource);

  Future<UserModel> login(String login, String password, String deviceName) async {
    try {
      final user = await _dataSource.login(login, password, deviceName);
      if (user.token != null) {
        await TokenManager.saveToken(user.token!);
      }
      return user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel?> me() async {
    final token = await TokenManager.getToken();
    if (token == null) return null;
    
    try {
      return await _dataSource.me();
    } catch (e) {
      await TokenManager.deleteToken();
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await TokenManager.deleteToken();
    }
  }

  Future<void> registerAdmin(Map<String, dynamic> data) async {
    try {
      await _dataSource.registerAdmin(data);
    } catch (e) {
       throw _handleError(e);
    }
  }

  Future<void> requestPasswordReset(String identifier) async {
    try {
      await _dataSource.requestPasswordReset(identifier);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetPassword(String identifier, String code, String password, String passwordConfirm) async {
    try {
      await _dataSource.resetPassword(identifier, code, password, passwordConfirm);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> verifyOtp(String login, String code) async {
    try {
      final user = await _dataSource.verifyOtp(login, code);
      if (user.token != null) {
        await TokenManager.saveToken(user.token!);
      }
      return user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resendOtp(String login, String password) async {
    try {
       await _dataSource.resendOtp(login, password);
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          if (data.containsKey('errors') && data['errors'] is Map) {
            final errors = data['errors'] as Map;
            return errors.values.join("\n");
          }
          if (data.containsKey('message')) {
            return data['message'];
          }
        }
      }
      return e.message ?? "Une erreur est survenue lors de l'authentification.";
    }
    return e.toString();
  }
}
