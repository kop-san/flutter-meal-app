import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_app/models/meal.dart';
import 'package:meal_app/services/favorites_service.dart';

class FavoritemealsNotifier extends StateNotifier<AsyncValue<List<Meal>>> {
  FavoritemealsNotifier() : super(const AsyncValue.loading()) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      state = const AsyncValue.loading();
      final favorites = await FavoritesService.getFavorites();
      state = AsyncValue.data(favorites);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleMealFavoriteStatus(Meal meal) async {
    try {
      final currentState = state;
      if (currentState is AsyncData<List<Meal>>) {
        final mealIsFavorite = currentState.value.any((m) => m.id == meal.id);
        
        if (mealIsFavorite) {
          // Optimistically update state
          state = AsyncValue.data(
            currentState.value.where((m) => m.id != meal.id).toList(),
          );
          // Make API call
          await FavoritesService.removeFavorite(meal.id);
        } else {
          // Optimistically update state
          state = AsyncValue.data([...currentState.value, meal]);
          // Make API call
          await FavoritesService.addFavorite(meal.id);
        }
      }
    } catch (error, stackTrace) {
      // Revert to previous state and show error
      state = AsyncValue.error(error, stackTrace);
      // Reload favorites to ensure consistency
      await _loadFavorites();
    }
  }

  bool isMealFavorite(String mealId) {
    final currentState = state;
    if (currentState is AsyncData<List<Meal>>) {
      return currentState.value.any((meal) => meal.id == mealId);
    }
    return false;
  }
}

final favoriteMealsProvider =
    StateNotifierProvider<FavoritemealsNotifier, AsyncValue<List<Meal>>>((ref) {
  return FavoritemealsNotifier();
});
