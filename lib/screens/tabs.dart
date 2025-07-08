import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meal_app/models/meal.dart';
import 'package:meal_app/screens/categories.dart';
import 'package:meal_app/screens/filters.dart';
import 'package:meal_app/screens/meals.dart';
import 'package:meal_app/screens/my_recipes.dart';
import 'package:meal_app/screens/add_recipe.dart';
import 'package:meal_app/widgets/main_drawer.dart';
import 'package:meal_app/providers/meals_provider.dart';
import 'package:meal_app/providers/favorites_provider.dart';
import 'package:meal_app/services/auth_service.dart';

const kInitialFilters = {
  Filter.glutenFree: false,
  Filter.lactoseFree: false,
  Filter.vegetarian: false,
  Filter.vegan: false,
};

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  int _selectedPageIndex = 0;
  Map<Filter, bool> _selectedFilters = kInitialFilters;

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _toggleMealFavoritesStatus(Meal meal) async {
    await ref
        .read(favoriteMealsProvider.notifier)
        .toggleMealFavoriteStatus(meal);
    if (context.mounted) {
      final isFavorite =
          ref.read(favoriteMealsProvider.notifier).isMealFavorite(meal.id);
      _showInfoMessage(
        isFavorite ? 'Marked as a favorite!' : 'Removed from favorites!',
      );
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _setScreen(String identifier) async {
    Navigator.of(context).pop();
    if (identifier == 'filters') {
      final result = await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(
            builder: (ctx) => FiltersScreen(
                  currentFilters: _selectedFilters,
                )),
      );

      setState(() {
        _selectedFilters = result ?? kInitialFilters;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealsAsync = ref.watch(mealsProvider);
    final favoritesAsync = ref.watch(favoriteMealsProvider);

    void handleLogout() async {
      await AuthService.logout();
      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }

    return mealsAsync.when(
      data: (meals) {
        final mealObjs = meals.map((m) => Meal.fromMap(m)).toList();
        final availableMeals = mealObjs.where((meal) {
          if (_selectedFilters[Filter.glutenFree]! && !meal.isGlutenFree) {
            return false;
          }
          if (_selectedFilters[Filter.lactoseFree]! && !meal.isLactoseFree) {
            return false;
          }
          if (_selectedFilters[Filter.vegetarian]! && !meal.isVegetarian) {
            return false;
          }
          if (_selectedFilters[Filter.vegan]! && !meal.isVegan) {
            return false;
          }
          return true;
        }).toList();

        Widget activePage = CategoriesScreen(
          onToggleFavorite: _toggleMealFavoritesStatus,
          availableMeals: availableMeals,
        );
        var activePageTitle = 'Categories';
        Widget? floatingActionButton;

        if (_selectedPageIndex == 1) {
          activePage = favoritesAsync.when(
            data: (favorites) => MealsScreen(
              meals: favorites,
              onToggleFavorite: _toggleMealFavoritesStatus,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'Error loading favorites: $error',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
          );
          activePageTitle = 'Your Favorites';
        } else if (_selectedPageIndex == 2) {
          activePage = const MyRecipesScreen();
          activePageTitle = 'My Recipes';
          floatingActionButton = FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const AddRecipeScreen()),
              );
              if (result == true && mounted) {
                setState(() {}); // Triggers MyRecipesScreen to reload
              }
            },
            tooltip: 'Add Recipe',
            child: const Icon(Icons.add),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(activePageTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search',
                onPressed: () {
                  Navigator.of(context).pushNamed('/search');
                },
              ),
              IconButton(
                icon: const Icon(Icons.person),
                tooltip: 'Profile',
                onPressed: () {
                  Navigator.of(context).pushNamed('/profile');
                },
              ),
            ],
          ),
          drawer: MainDrawer(
            onSelectScreen: _setScreen,
            onLogout: handleLogout,
          ),
          body: activePage,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: BottomNavigationBar(
            onTap: _selectPage,
            currentIndex: _selectedPageIndex,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.set_meal), label: 'Categories'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.star), label: 'Favorites'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.book), label: 'My Recipes'),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
