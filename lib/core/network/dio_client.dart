import 'package:dio/dio.dart';
import '../utils/token_manager.dart';

class DioClient {
  static final DioClient _singleton = DioClient._internal();
  late final Dio _dio;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrlValue,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      LogInterceptor(requestBody: true, responseBody: true),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    ]);
  }

  static String get _baseUrlValue {
    return 'http://192.168.1.15:8000/api';
  }

  static Dio get instance => _singleton._dio;
}
