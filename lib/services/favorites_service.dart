import 'dart:convert';
import 'package:meal_app/services/api_service.dart';
import 'package:meal_app/models/meal.dart';

class FavoritesService {
  static Future<List<Meal>> getFavorites() async {
    try {
      final response = await ApiService.get('/favorites');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data'])
            .map((meal) => Meal.fromMap(meal))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch favorites');
      }
    } catch (e) {
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  static Future<void> addFavorite(String recipeId) async {
    try {
      final response = await ApiService.post('/favorites/$recipeId', body: {});
      final data = jsonDecode(response.body);
      if (response.statusCode != 201) {
        throw Exception(data['message'] ?? 'Failed to add favorite');
      }
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  static Future<void> removeFavorite(String recipeId) async {
    try {
      final response = await ApiService.delete('/favorites/$recipeId');
      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to remove favorite');
      }
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }
}
