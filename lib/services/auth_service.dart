import 'dart:convert';
import 'package:meal_app/services/api_service.dart';

class AuthError extends Error {
  final String message;
  final int? statusCode;

  AuthError(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post('/auth/register', body: {
        'name': name,
        'email': email,
        'password': password,
      });
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['data'] != null) {
        await ApiService.setToken(data['data']['token']);
        return data['data']['user'];
      } else {
        throw AuthError(
          data['message'] ?? 'Registration failed. Please try again.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError(
        'Unable to register. Please check your connection and try again.',
      );
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post('/auth/login', body: {
        'email': email,
        'password': password,
      });
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['data'] != null) {
        await ApiService.setToken(data['data']['token']);
        return data['data']['user'];
      } else {
        throw AuthError(
          data['message'] ?? 'Invalid email or password.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError(
        'Unable to login. Please check your connection and try again.',
      );
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await ApiService.get('/auth/profile');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['data'] != null) {
        return data['data'];
      } else {
        throw AuthError(
          data['message'] ?? 'Failed to fetch profile.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError(
        'Unable to load profile. Please check your connection and try again.',
      );
    }
  }

  static Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final response = await ApiService.put('/user/profile', body: {
        'name': name,
        'email': email,
      });
      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw AuthError(
          data['message'] ?? 'Failed to update profile.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError(
        'Unable to update profile. Please check your connection and try again.',
      );
    }
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.put('/user/change-password', body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw AuthError(
          data['message'] ?? 'Failed to change password.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError(
        'Unable to change password. Please check your connection and try again.',
      );
    }
  }

  static Future<void> logout() async {
    try {
      await ApiService.clearToken();
    } catch (e) {
      throw AuthError('Failed to logout. Please try again.');
    }
  }
}
