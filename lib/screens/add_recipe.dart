import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meal_app/services/api_service.dart';
import 'package:meal_app/models/meal.dart';

class AddRecipeScreen extends StatefulWidget {
  final Map<String, dynamic>? recipe;
  final bool isEdit;
  const AddRecipeScreen({super.key, this.recipe, this.isEdit = false});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String? _error;

  // Form fields
  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  List<TextEditingController> _ingredientControllers = [
    TextEditingController()
  ];
  List<TextEditingController> _stepControllers = [TextEditingController()];
  List<String> _selectedCategoryIds = [];
  bool _isGlutenFree = false;
  bool _isVegan = false;
  bool _isVegetarian = false;
  bool _isLactoseFree = false;
  Complexity _complexity = Complexity.simple;
  Affordability _affordability = Affordability.affordable;
  List<dynamic> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    if (widget.isEdit && widget.recipe != null) {
      final r = widget.recipe!;
      _titleController.text = r['title'] ?? '';
      _imageUrlController.text = r['imageUrl'] ?? '';
      _descriptionController.text = r['description'] ?? '';
      _durationController.text = r['duration']?.toString() ?? '';
      _ingredientControllers = (r['ingredients'] as List?)
              ?.map((i) => TextEditingController(text: i.toString()))
              .toList() ??
          [TextEditingController()];
      _stepControllers = (r['steps'] as List?)
              ?.map((s) => TextEditingController(text: s.toString()))
              .toList() ??
          [TextEditingController()];
      _selectedCategoryIds =
          (r['categories'] as List?)?.map((c) => c['id'].toString()).toList() ??
              [];
      _isGlutenFree = r['isGlutenFree'] ?? false;
      _isVegan = r['isVegan'] ?? false;
      _isVegetarian = r['isVegetarian'] ?? false;
      _isLactoseFree = r['isLactoseFree'] ?? false;
      _complexity = _parseComplexity(r['complexity']);
      _affordability = _parseAffordability(r['affordability']);
    }
  }

  Complexity _parseComplexity(String? value) {
    switch (value) {
      case 'challenging':
        return Complexity.challenging;
      case 'hard':
        return Complexity.hard;
      default:
        return Complexity.simple;
    }
  }

  Affordability _parseAffordability(String? value) {
    switch (value) {
      case 'pricey':
        return Affordability.pricey;
      case 'luxurious':
        return Affordability.luxurious;
      default:
        return Affordability.affordable;
    }
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    try {
      final response = await ApiService.get('/categories');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['data'] != null) {
        setState(() {
          _categories = data['data'];
          _isLoadingCategories = false;
        });
      } else {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      if (_ingredientControllers.length > 1) {
        _ingredientControllers.removeAt(index);
      }
    });
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStepField(int index) {
    setState(() {
      if (_stepControllers.length > 1) {
        _stepControllers.removeAt(index);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final body = {
        'title': _titleController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'description': _descriptionController.text.trim(),
        'duration': int.tryParse(_durationController.text.trim()) ?? 0,
        'ingredients': _ingredientControllers
            .map((c) => c.text.trim())
            .where((v) => v.isNotEmpty)
            .toList(),
        'steps': _stepControllers
            .map((c) => c.text.trim())
            .where((v) => v.isNotEmpty)
            .toList(),
        'categoryIds': _selectedCategoryIds,
        'isGlutenFree': _isGlutenFree,
        'isVegan': _isVegan,
        'isVegetarian': _isVegetarian,
        'isLactoseFree': _isLactoseFree,
        'complexity': _complexity.name,
        'affordability': _affordability.name,
      };
      final response = widget.isEdit && widget.recipe != null
          ? await ApiService.put('/recipes/${widget.recipe!['id']}', body: body)
          : await ApiService.post('/recipes', body: body);
      final data = jsonDecode(response.body);
      if ((widget.isEdit && response.statusCode == 200) ||
          (!widget.isEdit && response.statusCode == 201)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(widget.isEdit ? 'Recipe updated!' : 'Recipe added!')));
          Navigator.of(context).pop(true); // Indicate success
        }
      } else {
        setState(() {
          _error = data['message'] ??
              'Failed to ${widget.isEdit ? 'update' : 'add'} recipe.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to ${widget.isEdit ? 'update' : 'add'} recipe.';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    for (final c in _ingredientControllers) {
      c.dispose();
    }
    for (final c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? 'Edit Recipe' : 'Add Recipe')),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                      ),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Basic Info',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                  labelText: 'Title',
                                  prefixIcon: Icon(Icons.title)),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Title required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _imageUrlController,
                              decoration: const InputDecoration(
                                  labelText: 'Image URL',
                                  prefixIcon: Icon(Icons.image)),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                  labelText: 'Description',
                                  prefixIcon: Icon(Icons.description)),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _durationController,
                              decoration: const InputDecoration(
                                  labelText: 'Duration (min)',
                                  prefixIcon: Icon(Icons.timer)),
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Duration required'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Ingredients',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            ..._ingredientControllers
                                .asMap()
                                .entries
                                .map((entry) {
                              final idx = entry.key;
                              final controller = entry.value;
                              return Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: controller,
                                      decoration: InputDecoration(
                                        labelText: 'Ingredient ${idx + 1}',
                                        prefixIcon: const Icon(Icons.list),
                                      ),
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                  ),
                                  if (_ingredientControllers.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _removeIngredientField(idx),
                                    ),
                                ],
                              );
                            }),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: _addIngredientField,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Ingredient'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Steps',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            ..._stepControllers.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final controller = entry.value;
                              return Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: controller,
                                      decoration: InputDecoration(
                                        labelText: 'Step ${idx + 1}',
                                        prefixIcon: const Icon(
                                            Icons.format_list_numbered),
                                      ),
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                  ),
                                  if (_stepControllers.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle,
                                          color: Colors.red),
                                      onPressed: () => _removeStepField(idx),
                                    ),
                                ],
                              );
                            }),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: _addStepField,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Step'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Categories',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: _categories.map<Widget>((cat) {
                                final selected =
                                    _selectedCategoryIds.contains(cat['id']);
                                return FilterChip(
                                  label: Text(cat['title']),
                                  selected: selected,
                                  onSelected: (val) {
                                    setState(() {
                                      if (val) {
                                        _selectedCategoryIds.add(cat['id']);
                                      } else {
                                        _selectedCategoryIds.remove(cat['id']);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Recipe Details',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<Complexity>(
                              value: _complexity,
                              decoration: const InputDecoration(
                                labelText: 'Complexity',
                                prefixIcon: Icon(Icons.trending_up),
                              ),
                              items: Complexity.values
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c.name[0].toUpperCase() +
                                            c.name.substring(1)),
                                      ))
                                  .toList(),
                              onChanged: (val) => setState(
                                  () => _complexity = val ?? Complexity.simple),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<Affordability>(
                              value: _affordability,
                              decoration: const InputDecoration(
                                labelText: 'Affordability',
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              items: Affordability.values
                                  .map((a) => DropdownMenuItem(
                                        value: a,
                                        child: Text(a.name[0].toUpperCase() +
                                            a.name.substring(1)),
                                      ))
                                  .toList(),
                              onChanged: (val) => setState(() =>
                                  _affordability =
                                      val ?? Affordability.affordable),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Dietary Flags',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            CheckboxListTile(
                              value: _isGlutenFree,
                              onChanged: (v) =>
                                  setState(() => _isGlutenFree = v ?? false),
                              title: const Text('Gluten Free'),
                            ),
                            CheckboxListTile(
                              value: _isVegan,
                              onChanged: (v) =>
                                  setState(() => _isVegan = v ?? false),
                              title: const Text('Vegan'),
                            ),
                            CheckboxListTile(
                              value: _isVegetarian,
                              onChanged: (v) =>
                                  setState(() => _isVegetarian = v ?? false),
                              title: const Text('Vegetarian'),
                            ),
                            CheckboxListTile(
                              value: _isLactoseFree,
                              onChanged: (v) =>
                                  setState(() => _isLactoseFree = v ?? false),
                              title: const Text('Lactose Free'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : Text(
                                widget.isEdit ? 'Update Recipe' : 'Add Recipe',
                                style: const TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
