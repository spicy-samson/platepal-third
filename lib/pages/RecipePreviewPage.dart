import 'package:flutter/material.dart';
import 'package:platepal/database_helper.dart';

class RecipePreviewPage extends StatefulWidget {
  final int recipeId;

  const RecipePreviewPage({Key? key, required this.recipeId}) : super(key: key);

  @override
  _RecipePreviewPageState createState() => _RecipePreviewPageState();
}

class _RecipePreviewPageState extends State<RecipePreviewPage> {
  late Future<Map<String, dynamic>> _recipeFuture;
  bool _isStarred = false;

  @override
  void initState() {
    super.initState();
    _recipeFuture = _loadRecipe();
  }

  Future<Map<String, dynamic>> _loadRecipe() async {
    final recipe = await DatabaseHelper.instance.getRecipe(widget.recipeId);
    setState(() {
      _isStarred = recipe['is_starred'] == 1;
    });
    return recipe;
  }

  Future<void> _toggleStarred() async {
    final newStarredValue = _isStarred ? 0 : 1;
    await DatabaseHelper.instance.updateRecipeStarred(widget.recipeId, newStarredValue);
    setState(() {
      _isStarred = !_isStarred;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Preview'),
        actions: [
          IconButton(
            icon: Icon(_isStarred ? Icons.star : Icons.star_border),
            onPressed: _toggleStarred,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No recipe data found.'));
          }

          final recipe = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe['name'],
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Category: ${recipe['category_name']}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Difficulty: ${recipe['difficulty']}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Instructions:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(recipe['instructions']),
                const SizedBox(height: 16),
                Text(
                  'Nutritional Information:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Calories: ${recipe['calories']}'),
                Text('Protein: ${recipe['protein']}g'),
                Text('Carbohydrates: ${recipe['carbohydrates']}g'),
                Text('Fat: ${recipe['fat']}g'),
                Text('Saturated Fat: ${recipe['saturated_fat']}g'),
                Text('Cholesterol: ${recipe['cholesterol']}mg'),
                Text('Sodium: ${recipe['sodium']}mg'),
              ],
            ),
          );
        },
      ),
    );
  }
}