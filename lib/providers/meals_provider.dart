import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_app/services/meal_service.dart';

final mealsProvider = FutureProvider((ref) async {
  return await MealService.fetchMeals();
});
