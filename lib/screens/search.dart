import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_app/models/meal.dart';
import 'package:meal_app/providers/meals_provider.dart';
import 'package:meal_app/widgets/meal_item.dart';
import 'package:meal_app/screens/meal_detials.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isGlutenFree = false;
  bool _isLactoseFree = false;
  bool _isVegan = false;
  bool _isVegetarian = false;
  Complexity? _selectedComplexity;
  Affordability? _selectedAffordability;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Meal> _filterMeals(List<Meal> meals) {
    return meals.where((meal) {
      final matchesQuery = _searchQuery.isEmpty ||
          meal.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          meal.ingredients.any((ingredient) =>
              ingredient.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesDietary = (!_isGlutenFree || meal.isGlutenFree) &&
          (!_isLactoseFree || meal.isLactoseFree) &&
          (!_isVegan || meal.isVegan) &&
          (!_isVegetarian || meal.isVegetarian);

      final matchesComplexity =
          _selectedComplexity == null || meal.complexity == _selectedComplexity;

      final matchesAffordability = _selectedAffordability == null ||
          meal.affordability == _selectedAffordability;

      return matchesQuery &&
          matchesDietary &&
          matchesComplexity &&
          matchesAffordability;
    }).toList();
  }

  void _selectMeal(BuildContext context, Meal meal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MealDetialsScreen(
          meal: meal,
          onToggleFavorite: (meal) {
            
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mealsData = ref.watch(mealsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Recipes'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search recipes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Gluten Free'),
                        selected: _isGlutenFree,
                        onSelected: (selected) {
                          setState(() {
                            _isGlutenFree = selected;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Lactose Free'),
                        selected: _isLactoseFree,
                        onSelected: (selected) {
                          setState(() {
                            _isLactoseFree = selected;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Vegan'),
                        selected: _isVegan,
                        onSelected: (selected) {
                          setState(() {
                            _isVegan = selected;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Vegetarian'),
                        selected: _isVegetarian,
                        onSelected: (selected) {
                          setState(() {
                            _isVegetarian = selected;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      DropdownButton<Complexity>(
                        hint: const Text('Complexity'),
                        value: _selectedComplexity,
                        items: Complexity.values
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.name.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedComplexity = value;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<Affordability>(
                        hint: const Text('Affordability'),
                        value: _selectedAffordability,
                        items: Affordability.values
                            .map((a) => DropdownMenuItem(
                                  value: a,
                                  child: Text(a.name.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAffordability = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: mealsData.when(
              data: (meals) {
                final List<Meal> mealsList =
                    meals.map((mealData) => Meal.fromMap(mealData)).toList();
                final filteredMeals = _filterMeals(mealsList);

                return filteredMeals.isEmpty
                    ? Center(
                        child: Text(
                          'No recipes found.',
                          style: theme.textTheme.titleLarge,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredMeals.length,
                        itemBuilder: (ctx, index) {
                          final meal = filteredMeals[index];
                          return MealItem(
                            meal: meal,
                            onSelectMeal: (meal) => _selectMeal(context, meal),
                          );
                        },
                      );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading meals: $error',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
