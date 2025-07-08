import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // TODO: Update this URL to match your backend server
  static const String baseUrl = 'http://localhost:3000/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    final token = await _storage.read(key: 'jwt_token');
    return token;
  }

  static Future<void> setToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  static Future<http.Response> get(String endpoint,
      {Map<String, String>? headers}) async {
    final token = await getToken();
    final allHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    return http.get(Uri.parse('$baseUrl$endpoint'), headers: allHeaders);
  }

  static Future<http.Response> post(String endpoint,
      {Map<String, String>? headers, Object? body}) async {
    final token = await getToken();
    final allHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    return http.post(Uri.parse('$baseUrl$endpoint'),
        headers: allHeaders, body: jsonEncode(body));
  }

  static Future<http.Response> put(String endpoint,
      {Map<String, String>? headers, Object? body}) async {
    final token = await getToken();
    final allHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    return http.put(Uri.parse('$baseUrl$endpoint'),
        headers: allHeaders, body: jsonEncode(body));
  }

  static Future<http.Response> delete(String endpoint,
      {Map<String, String>? headers}) async {
    final token = await getToken();
    final allHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    return http.delete(Uri.parse('$baseUrl$endpoint'), headers: allHeaders);
  }
}
