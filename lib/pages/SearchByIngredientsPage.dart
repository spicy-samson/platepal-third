import 'package:flutter/material.dart';
import 'package:platepal/components/IngredientItem.dart';
import 'package:platepal/components/SelectedIngredientItem.dart';
import 'package:platepal/models/ingredient.dart';
import 'package:platepal/database_helper.dart';
import 'package:platepal/pages/RecipePreviewPage.dart';

class SearchByIngredientsPage extends StatefulWidget {
  const SearchByIngredientsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchByIngredientsPageState createState() => _SearchByIngredientsPageState();
}

class _SearchByIngredientsPageState extends State<SearchByIngredientsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> ingredientCategories = ['All', 'Meat', 'Vegetables and Fruits', 'Seafood', 'Spices and herbs', 'Condiments'];
  List<Ingredient> selectedIngredients = [];
  Map<String, List<Ingredient>> categoryIngredients = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: ingredientCategories.length, vsync: this);
    _loadIngredients();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadIngredients() async {
    final ingredients = await DatabaseHelper.instance.queryAllIngredients();
    setState(() {
      for (var category in ingredientCategories) {
        categoryIngredients[category] = ingredients
            .map((map) => Ingredient.fromMap(map))
            .where((ingredient) => category == 'All' || ingredient.category == category)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search by Ingredients'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: ingredientCategories.map((category) => Tab(text: category)).toList(),
        ),
      ),
      body: Column(
        children: [
          _buildSelectedIngredients(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: ingredientCategories.map((category) => _buildIngredientGrid(category)).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _searchRecipes,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Search Recipes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedIngredients() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: selectedIngredients.isEmpty
          ? const Center(child: Text('Select ingredients to start'))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedIngredients.length,
              itemBuilder: (context, index) {
                return SelectedIngredientItem(
                  ingredient: selectedIngredients[index],
                  onRemove: () {
                    setState(() {
                      selectedIngredients.removeAt(index);
                    });
                  },
                );
              },
            ),
    );
  }

  Widget _buildIngredientGrid(String category) {
    List<Ingredient> ingredients = categoryIngredients[category] ?? [];

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        return IngredientItem(
          ingredient: ingredients[index],
          isSelected: selectedIngredients.contains(ingredients[index]),
          onTap: () {
            setState(() {
              if (selectedIngredients.contains(ingredients[index])) {
                selectedIngredients.remove(ingredients[index]);
              } else {
                selectedIngredients.add(ingredients[index]);
              }
            });
          },
        );
      },
    );
  }

  void _searchRecipes() async {
    if (selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one ingredient')),
      );
      return;
    }

    List<int> selectedIngredientIds = selectedIngredients.map((i) => i.id).toList();
    final recipes = await DatabaseHelper.instance.searchRecipesByIngredients(selectedIngredientIds);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeListPage(recipes: recipes),
      ),
    );
  }
}

class RecipeListPage extends StatelessWidget {
  final List<Map<String, dynamic>> recipes;

  const RecipeListPage({Key? key, required this.recipes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matching Recipes')),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return ListTile(
            title: Text(recipe['name']),
            subtitle: Text('Matched: ${recipe['matched_ingredients']} / ${recipe['total_ingredients']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipePreviewPage(recipeId: recipe['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}