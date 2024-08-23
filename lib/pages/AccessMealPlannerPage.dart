import 'package:flutter/material.dart';
import 'package:platepal/database_helper.dart';
import 'package:platepal/pages/RecipePreviewPage.dart';
import 'package:platepal/components/AppBar.dart';

class MealPlannerPage extends StatefulWidget {
  const MealPlannerPage({super.key});

  @override
  State<MealPlannerPage> createState() => _MealPlannerPageState();
}

class _MealPlannerPageState extends State<MealPlannerPage> {
  final Map<String, Map<String, String>> mealPlan = {
    'Monday': {}, 'Tuesday': {}, 'Wednesday': {}, 'Thursday': {}, 'Friday': {}, 'Saturday': {}, 'Sunday': {},
  };
  List<Map<String, dynamic>> recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _loadMealPlan();
  }

  Future<void> _loadRecipes() async {
    final loadedRecipes = await DatabaseHelper.instance.queryAllRecipes();
    setState(() {
      recipes = loadedRecipes;
    });
  }

  Future<void> _loadMealPlan() async {
    final loadedMealPlan = await DatabaseHelper.instance.getMealPlan();
    setState(() {
      for (var meal in loadedMealPlan) {
        mealPlan[meal['day_of_week']]?[meal['meal_of_day']] = meal['recipe_name'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: const CustomAppBar(title: 'Meal Planner'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weekly Meal Planner',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A), // Slate 900
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final day = _getDay(index);
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(
                            day,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF334155), // Slate 700
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildMealSection('Breakfast', day),
                                  _buildMealSection('Lunch', day),
                                  _buildMealSection('Dinner', day),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDay(int index) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[index];
  }

  Widget _buildMealSection(String mealType, String day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mealType,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569), // Slate 600
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9), // Slate 100
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    mealPlan[day]?[mealType] ?? 'Add a meal',
                    style: TextStyle(
                      fontSize: 14,
                      color: mealPlan[day]?[mealType] != null ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                    ),
                  ),
                ),
                if (mealPlan[day]?[mealType] != null)
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Color(0xFF64748B)),
                    onPressed: () => _previewRecipe(mealPlan[day]![mealType]!),
                  ),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF64748B)),
                  onPressed: () => _showAddMealDialog(context, day, mealType),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMealDialog(BuildContext context, String day, String mealType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add $mealType for $day'),
          content: SingleChildScrollView(
            child: ListBody(
              children: recipes.map((recipe) => 
                ListTile(
                  title: Text(recipe['name']),
                  onTap: () {
                    _updateMealPlan(day, mealType, recipe['id'], recipe['name']);
                    Navigator.of(context).pop();
                  },
                )
              ).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateMealPlan(String day, String mealType, int recipeId, String recipeName) async {
    await DatabaseHelper.instance.updateMealPlan(day, mealType, recipeId);
    setState(() {
      mealPlan[day]?[mealType] = recipeName;
    });
  }

  void _previewRecipe(String recipeName) {
    final recipe = recipes.firstWhere((r) => r['name'] == recipeName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipePreviewPage(recipeId: recipe['id']),
      ),
    ).then((_) => _loadRecipes()); // Reload recipes after returning from preview
  }
}