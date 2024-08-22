import 'package:flutter/material.dart';
import 'package:platepal/database_helper.dart';

class RecipePreviewPage extends StatefulWidget {
  final int recipeId;

  const RecipePreviewPage({super.key, required this.recipeId});

  @override
  // ignore: library_private_types_in_public_api
  _RecipePreviewPageState createState() => _RecipePreviewPageState();
}

class _RecipePreviewPageState extends State<RecipePreviewPage> {
  late Future<Map<String, dynamic>> _recipeFuture;
  late Future<List<Map<String, dynamic>>> _ingredientsFuture;
  bool _isStarred = false;

  @override
  void initState() {
    super.initState();
    _recipeFuture = _loadRecipe();
    _ingredientsFuture = _loadIngredients();
  }

  Future<Map<String, dynamic>> _loadRecipe() async {
    final recipe = await DatabaseHelper.instance.getRecipe(widget.recipeId);
    setState(() {
      _isStarred = recipe['is_starred'] == 1;
    });
    return recipe;
  }

  Future<List<Map<String, dynamic>>> _loadIngredients() async {
    return await DatabaseHelper.instance.getRecipeIngredients(widget.recipeId);
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _recipeFuture,
        builder: (context, recipeSnapshot) {
          if (recipeSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (recipeSnapshot.hasError) {
            return Center(child: Text('Error: ${recipeSnapshot.error}'));
          } else if (!recipeSnapshot.hasData) {
            return const Center(child: Text('No recipe data found.'));
          }

          final recipe = recipeSnapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(recipe['name']),
                  background: Image.asset(
                    'assets/images/${recipe['image'] ?? 'default_recipe.jpg'}',
                    fit: BoxFit.cover,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(_isStarred ? Icons.star : Icons.star_border),
                    onPressed: _toggleStarred,
                    color: Colors.amber,
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRecipeInfo(recipe),
                      const SizedBox(height: 16),
                      _buildIngredientsCard(),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        title: 'Instructions',
                        content: _buildNumberedInstructions(recipe['instructions']),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        title: 'Nutritional Information',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNutritionRow('Calories', recipe['calories'], 'kcal'),
                            _buildNutritionRow('Protein', recipe['protein'], 'g'),
                            _buildNutritionRow('Carbohydrates', recipe['carbohydrates'], 'g'),
                            _buildNutritionRow('Fat', recipe['fat'], 'g'),
                            _buildNutritionRow('Saturated Fat', recipe['saturated_fat'], 'g'),
                            _buildNutritionRow('Cholesterol', recipe['cholesterol'], 'mg'),
                            _buildNutritionRow('Sodium', recipe['sodium'], 'mg'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecipeInfo(Map<String, dynamic> recipe) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Difficulty',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                recipe['difficulty'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Servings',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                '${recipe['servings'] ?? "1-2 Servings"}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsCard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _ingredientsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No ingredients found.'));
        }

        final ingredients = snapshot.data!;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...ingredients.map((ingredient) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text('${ingredient['quantity']} ${ingredient['name']}'),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({required String title, required Widget content}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, dynamic value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text('$value $unit'),
        ],
      ),
    );
  }

  Widget _buildNumberedInstructions(String instructions) {
    List<String> steps = instructions.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: steps.asMap().entries.map((entry) {
        int idx = entry.key;
        String step = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text("${idx + 1}. $step"),
        );
      }).toList(),
    );
  }
}