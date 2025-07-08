enum Complexity {
  simple,
  challenging,
  hard,
}

enum Affordability {
  affordable,
  pricey,
  luxurious,
}

class Meal {
  const Meal({
    required this.id,
    required this.categories,
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.duration,
    required this.complexity,
    required this.affordability,
    required this.isGlutenFree,
    required this.isLactoseFree,
    required this.isVegan,
    required this.isVegetarian,
  });

  final String id;
  final List<String> categories;
  final String title;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  final int duration;
  final Complexity complexity;
  final Affordability affordability;
  final bool isGlutenFree;
  final bool isLactoseFree;
  final bool isVegan;
  final bool isVegetarian;

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as String,
      categories: (map['categories'] as List)
          .map((c) => c is String ? c : c['id'] as String)
          .toList(),
      title: map['title'] as String,
      imageUrl: map['imageUrl'] as String? ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      duration: map['duration'] as int? ?? 0,
      complexity: Complexity
          .simple, // You may want to map this if your backend supports it
      affordability: Affordability.affordable, // Same as above
      isGlutenFree: map['isGlutenFree'] as bool? ?? false,
      isLactoseFree: map['isLactoseFree'] as bool? ?? false,
      isVegan: map['isVegan'] as bool? ?? false,
      isVegetarian: map['isVegetarian'] as bool? ?? false,
    );
  }
}
