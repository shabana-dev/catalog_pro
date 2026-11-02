import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class ApiService {
  final Dio _dio;
  final SecureStorage _secureStorage;

  ApiService(this._dio, this._secureStorage) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<Response> login(String username, String password) async {
    return await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
  }

  Future<Response> getProducts({int limit = 20, int skip = 0}) async {
    return await _dio.get('/products', queryParameters: {
      'limit': limit,
      'skip': skip,
    });
  }

  Future<Response> searchProducts(String query) async {
    return await _dio.get('/products/search', queryParameters: {'q': query});
  }

  Future<Response> getProduct(int id) async {
    return await _dio.get('/products/$id');
  }
}
