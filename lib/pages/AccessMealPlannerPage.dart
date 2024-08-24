import 'package:flutter/material.dart';
import 'package:platepal/database_helper.dart';
import 'package:platepal/pages/RecipePreviewPage.dart';
import 'package:platepal/components/AppBar.dart';
import 'package:platepal/components/MealPlannerRecipeCard.dart';
import 'package:platepal/components/MealPlannerRecipePreview.dart';

class MealPlannerPage extends StatefulWidget {
  const MealPlannerPage({super.key});

  @override
  State<MealPlannerPage> createState() => _MealPlannerPageState();
}

class _MealPlannerPageState extends State<MealPlannerPage> {
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner'];
  late List<String> orderedDays;
  late String currentDay;
  late String currentMealType;
  final Map<String, Map<String, String>> mealPlan = {
    'Monday': {}, 'Tuesday': {}, 'Wednesday': {}, 'Thursday': {}, 'Friday': {}, 'Saturday': {}, 'Sunday': {},
  };
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _initializeCurrentDayAndMeal();
    _loadRecipes();
    _loadMealPlan();
  }

  void _initializeCurrentDayAndMeal() {
    final now = DateTime.now();
    currentDay = days[now.weekday - 1];
    if (now.hour < 11) {
      currentMealType = 'Breakfast';
    } else if (now.hour < 16) {
      currentMealType = 'Lunch';
    } else {
      currentMealType = 'Dinner';
    }
    
    int currentIndex = days.indexOf(currentDay);
    orderedDays = [...days.sublist(currentIndex), ...days.sublist(0, currentIndex)];
  }

  Future<void> _loadRecipes() async {
    final loadedRecipes = await DatabaseHelper.instance.queryAllRecipes();
    if (mounted) {
      setState(() {
        recipes = loadedRecipes;
        _searchResults = loadedRecipes;
      });
    }
  }

  Future<void> _loadMealPlan() async {
    final loadedMealPlan = await DatabaseHelper.instance.getMealPlan();
    if (mounted) {
      setState(() {
        for (var meal in loadedMealPlan) {
          mealPlan[meal['day_of_week']]?[meal['meal_of_day']] = meal['recipe_name'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _initializeCurrentDayAndMeal();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'Meal Planner'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today is $currentDay',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final day = orderedDays[index];
                    return _buildDayCard(day);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard(String day) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: day == currentDay ? const Color(0xFFE2E8F0) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: day == currentDay,
          title: Text(
            day,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: day == currentDay ? const Color(0xFF2563EB) : const Color(0xFF334155),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: mealTypes.map((mealType) => _buildMealSection(mealType, day)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String mealType, String day) {
    bool isCurrentMeal = day == currentDay && mealType == currentMealType;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mealType,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isCurrentMeal ? const Color(0xFF2563EB) : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isCurrentMeal ? const Color(0xFFBFDBFE) : const Color(0xFFF1F5F9),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, controller) {
                return Column(
                  children: [
                    AppBar(
                      title: Text('Add $mealType for $day'),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search recipes...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        onChanged: (query) {
                          setModalState(() {
                            if (query.isEmpty) {
                              _searchResults = List.from(recipes); // Create a new list with all recipes
                            } else {
                              _searchResults = recipes
                                  .where((recipe) => recipe['name']
                                      .toLowerCase()
                                      .contains(query.toLowerCase()))
                                  .toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: MealPlannerRecipeCard(
                              recipe: _searchResults[index],
                              onAdd: () {
                                _updateMealPlan(day, mealType, _searchResults[index]['id'], _searchResults[index]['name']);
                                Navigator.of(context).pop();
                              },
                              onPreview: () => _showRecipePreview(_searchResults[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
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
    ).then((_) => _loadRecipes());
  }

  void _showRecipePreview(Map<String, dynamic> recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MealPlannerRecipePreview(
          recipe: recipe,
          onAdd: () {
            _updateMealPlan(currentDay, currentMealType, recipe['id'], recipe['name']);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}