import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_config.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// =========================
  /// AUTH - LOGIN
  /// =========================
  static Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        if (token != null) {
          await _saveToken(token);
          _dio.options.headers['Authorization'] = 'Bearer $token';
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// =========================
  /// AUTH - REGISTER
  /// =========================
  static Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// =========================
  /// LOAD TOKEN (AUTO LOGIN)
  /// =========================
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// =========================
  /// LOGOUT
  /// =========================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _dio.options.headers.remove('Authorization');
  }

  /// =========================
  /// CHANGE PASSWORD
  /// =========================
  static Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _dio.put(
        '/users/me/password',
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  /// =========================
  /// EVENTS
  /// =========================
  static Future<Response> getEvents() async {
    return await _dio.get('/events');
  }

  static Future<Response> addEvent(Map<String, dynamic> data) async {
    return await _dio.post('/events', data: data);
  }

  static Future<Response> updateEvent(int id, Map<String, dynamic> data) async {
    return await _dio.put('/events/$id', data: data);
  }

  static Future<Response> deleteEvent(int id) async {
    return await _dio.delete('/events/$id');
  }
}
