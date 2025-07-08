import 'package:flutter/material.dart';
import 'package:meal_app/models/meal.dart';
import 'package:meal_app/services/meal_service.dart';

class MealDetialsScreen extends StatefulWidget {
  const MealDetialsScreen({
    super.key,
    required this.meal,
    required this.onToggleFavorite,
    this.isUserRecipe = false,
  });

  final Meal meal;
  final void Function(Meal meal) onToggleFavorite;
  final bool isUserRecipe;

  @override
  State<MealDetialsScreen> createState() => _MealDetialsScreenState();
}

class _MealDetialsScreenState extends State<MealDetialsScreen> {
  bool _isDeleting = false;

  Future<void> _deleteRecipe() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text(
            'Are you sure you want to delete this recipe? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await MealService.deleteRecipe(widget.meal.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal.title),
        actions: [
          if (widget.isUserRecipe)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isDeleting ? null : _deleteRecipe,
              tooltip: 'Delete Recipe',
            ),
          IconButton(
            onPressed: () {
              widget.onToggleFavorite(widget.meal);
            },
            icon: const Icon(Icons.star),
            tooltip: 'Toggle Favorite',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Hero(
                  tag: widget.meal.id,
                  child: Image.network(
                    widget.meal.imageUrl,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 300,
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.white54,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 300,
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Ingredients',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 14),
                for (final ingredient in widget.meal.ingredients)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      ingredient,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Steps',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 14),
                for (final step in widget.meal.steps)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    child: Text(
                      step,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_isDeleting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
