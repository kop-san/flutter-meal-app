import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meal_app/services/api_service.dart';
import 'package:meal_app/screens/add_recipe.dart';

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _recipes = [];

  @override
  void initState() {
    super.initState();
    _fetchMyRecipes();
  }

  Future<void> _fetchMyRecipes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await ApiService.get('/user/recipes');
      final decoded = Map<String, dynamic>.from(jsonDecode(response.body));
      if (response.statusCode == 200 && decoded['data'] != null) {
        setState(() {
          _recipes = decoded['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = decoded['message'] ?? 'Failed to fetch recipes.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch recipes.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : _recipes.isEmpty
                  ? const Center(
                      child: Text('You have not created any recipes yet.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _recipes.length,
                      itemBuilder: (ctx, i) {
                        final recipe = _recipes[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.hardEdge,
                          elevation: 3,
                          child: Stack(
                            children: [
                              recipe['imageUrl'] != null &&
                                      recipe['imageUrl'].toString().isNotEmpty
                                  ? Image.network(
                                      recipe['imageUrl'],
                                      fit: BoxFit.cover,
                                      height: 200,
                                      width: double.infinity,
                                    )
                                  : Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: theme.colorScheme.primaryContainer,
                                      child: const Icon(Icons.fastfood,
                                          size: 60, color: Colors.white),
                                    ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white, size: 24),
                                      tooltip: 'Edit',
                                      onPressed: () async {
                                        final result =
                                            await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (ctx) => AddRecipeScreen(
                                              recipe: recipe,
                                              isEdit: true,
                                            ),
                                          ),
                                        );
                                        if (result == true) _fetchMyRecipes();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.white, size: 24),
                                      tooltip: 'Delete',
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Delete Recipe'),
                                            content: const Text(
                                                'Are you sure you want to delete this recipe?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(ctx)
                                                        .pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(ctx).pop(true),
                                                child: const Text('Delete',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          try {
                                            final response =
                                                await ApiService.delete(
                                                    '/recipes/${recipe['id']}');
                                            final data =
                                                jsonDecode(response.body);
                                            if (response.statusCode == 200) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        content: Text(
                                                            'Recipe deleted!')));
                                                _fetchMyRecipes();
                                              }
                                            } else {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(data[
                                                                'message'] ??
                                                            'Failed to delete recipe')));
                                              }
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Failed to delete recipe')));
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black54,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 44),
                                  child: Column(
                                    children: [
                                      Text(
                                        recipe['title'] ?? '',
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (recipe['duration'] != null)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.schedule,
                                                size: 17, color: Colors.white),
                                            const SizedBox(width: 6),
                                            Text('${recipe['duration']} min',
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                          ],
                                        ),
                                      if (recipe['categories'] != null &&
                                          recipe['categories'].isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Wrap(
                                            spacing: 8,
                                            children: List<Widget>.from(
                                              recipe['categories']
                                                  .map<Widget>((cat) => Chip(
                                                        label: Text(
                                                            cat['title'],
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                        backgroundColor: theme
                                                            .colorScheme
                                                            .primary,
                                                      )),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
