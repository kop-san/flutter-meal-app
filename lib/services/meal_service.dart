import 'dart:convert';
import 'package:meal_app/services/api_service.dart';
import 'package:meal_app/models/category.dart';
import 'package:flutter/material.dart';

class MealService {
  static Future<List<Map<String, dynamic>>> fetchMeals() async {
    try {
      final response = await ApiService.get('/recipes');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch meals');
      }
    } catch (e) {
      throw Exception(
          'Unable to load recipes. Please check your connection and try again.');
    }
  }

  static Future<List<Category>> fetchCategories() async {
    try {
      final response = await ApiService.get('/categories');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data'])
            .map((cat) => Category(
                  id: cat['id'],
                  title: cat['title'],
                  color: _parseColor(cat['color']),
                ))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch categories');
      }
    } catch (e) {
      throw Exception(
          'Unable to load categories. Please check your connection and try again.');
    }
  }

  static Future<void> deleteRecipe(String recipeId) async {
    try {
      final response = await ApiService.delete('/recipes/$recipeId');
      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to delete recipe');
      }
    } catch (e) {
      throw Exception('Unable to delete recipe. Please try again later.');
    }
  }
}

Color _parseColor(String? colorString) {
  if (colorString == null || colorString.isEmpty) return Colors.orange;
  try {
    return Color(int.parse(colorString.replaceFirst('#', '0xff')));
  } catch (_) {
    return Colors.orange;
  }
}
