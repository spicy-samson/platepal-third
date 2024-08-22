import 'package:flutter/material.dart';
import 'package:platepal/database_helper.dart';
import 'package:platepal/components/RecipeCard.dart';

class SearchByRecipePage extends StatefulWidget {
  const SearchByRecipePage({Key? key}) : super(key: key);

  @override
  _SearchByRecipePageState createState() => _SearchByRecipePageState();
}

class _SearchByRecipePageState extends State<SearchByRecipePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _recipes = [];
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Dish', 'Dessert', 'Snack', 'Dietary'];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final recipes = await DatabaseHelper.instance.queryAllRecipes();
    setState(() {
      _recipes = recipes;
    });
  }

  void _searchRecipes(String query) async {
    if (query.isEmpty) {
      await _loadRecipes();
    } else {
      final recipes = await DatabaseHelper.instance.searchRecipes(query);
      setState(() {
        _recipes = recipes;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredRecipes() {
    if (_selectedCategory == 'All') {
      return _recipes;
    } else {
      return _recipes.where((recipe) => recipe['category_name'] == _selectedCategory).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What to cook?'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onChanged: _searchRecipes,
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _getFilteredRecipes().length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: RecipeCard(recipe: _getFilteredRecipes()[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}