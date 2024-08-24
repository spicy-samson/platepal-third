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

class _SearchByIngredientsPageState extends State<SearchByIngredientsPage> {
  List<String> categories = ['All', 'Dish', 'Dessert', 'Snack', 'Dietary'];
  List<String> ingredientCategories = ['All', 'Meat', 'Vegetables and Fruits', 'Seafood', 'Spices and herbs', 'Condiments'];
  String selectedCategory = 'All';
  String selectedIngredientCategory = 'All';
  List<Ingredient> selectedIngredients = [];
  List<Ingredient> availableIngredients = [];

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    final ingredients = await DatabaseHelper.instance.queryAllIngredients();
    setState(() {
      availableIngredients = ingredients.map((map) => Ingredient.fromMap(map)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('What to cook?')),
      body: Column(
        children: [
          _buildCategoryFilter(),
          _buildSelectedIngredients(),
          Text('What\'s your Ingredients?', style: Theme.of(context).textTheme.titleLarge),
          _buildIngredientCategoryFilter(),
          Expanded(child: _buildIngredientGrid()),
          ElevatedButton(
            onPressed: _searchRecipes,
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: selectedCategory == category,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedIngredients() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
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

  Widget _buildIngredientCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ingredientCategories.map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: selectedIngredientCategory == category,
              onSelected: (selected) {
                setState(() {
                  selectedIngredientCategory = category;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIngredientGrid() {
    List<Ingredient> filteredIngredients = selectedIngredientCategory == 'All'
        ? availableIngredients
        : availableIngredients.where((ingredient) => ingredient.category == selectedIngredientCategory).toList();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredIngredients.length,
      itemBuilder: (context, index) {
        return IngredientItem(
          ingredient: filteredIngredients[index],
          isSelected: selectedIngredients.contains(filteredIngredients[index]),
          onTap: () {
            setState(() {
              if (selectedIngredients.contains(filteredIngredients[index])) {
                selectedIngredients.remove(filteredIngredients[index]);
              } else {
                selectedIngredients.add(filteredIngredients[index]);
              }
            });
          },
        );
      },
    );
  }

  void _searchRecipes() async {
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