import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';
import '../../../../core/utils/token_manager.dart';

class AuthRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<UserModel> login(String login, String password, String deviceName) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'login': login,
        'password': password,
        'device_name': deviceName,
      });
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Fallback 1: common /login endpoint (still under baseUrl)
        try {
          final fallback = await _dio.post('/login', data: {
            'login': login,
            'password': password,
            'device_name': deviceName,
          });
          return UserModel.fromJson(fallback.data);
        } on DioException {
          // Fallback 2: baseUrl without /api prefix (backend may not be namespaced)
          final baseUrl = _dio.options.baseUrl;
          final altBase = baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
          if (altBase != baseUrl && altBase.isNotEmpty) {
            final altResponse = await _dio.post(
              '$altBase/auth/login',
              data: {
                'login': login,
                'password': password,
                'device_name': deviceName,
              },
            );
            return UserModel.fromJson(altResponse.data);
          }
        }
      }
      rethrow;
    }
  }

  Future<UserModel> me() async {
    final token = await TokenManager.getToken();
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data, token: token);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<void> registerAdmin(Map<String, dynamic> data) async {
    // Admin setup endpoint (snake_case used by Laravel)
    await _dio.post('/auth/setup-admin', data: data);
  }

  Future<void> requestPasswordReset(String identifier) async {
    // CORRECT ENDPOINT: auth/forgot-password/request-code
    // CORRECT KEYS: identifier, method
    await _dio.post('/auth/forgot-password/request-code', data: {
      'identifier': identifier,
      'method': 'email',
    });
  }

  Future<void> resetPassword(String identifier, String code, String password, String passwordConfirm) async {
    // CORRECT ENDPOINT: auth/forgot-password/reset
    // CORRECT KEYS: identifier, method, otp, new_password, new_password_confirmation
    await _dio.post('/auth/forgot-password/reset', data: {
      'identifier': identifier,
      'method': 'email',
      'otp': code,
      'new_password': password,
      'new_password_confirmation': passwordConfirm,
    });
  }

  Future<UserModel> verifyOtp(String login, String code) async {
    // CORRECT KEY: otp
    final response = await _dio.post('/auth/verify-otp', data: {
      'login': login,
      'otp': code,
    });
    return UserModel.fromJson(response.data);
  }

  Future<void> resendOtp(String login, String password) async {
    // CORRECT ENDPOINT: auth/request-otp
    await _dio.post('/auth/request-otp', data: {
      'login': login,
      'password': password,
    });
  }
}
