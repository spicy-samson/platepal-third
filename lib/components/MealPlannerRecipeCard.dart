import 'package:flutter/material.dart';

class MealPlannerRecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback onAdd;
  final VoidCallback onPreview;

  const MealPlannerRecipeCard({
    super.key,
    required this.recipe,
    required this.onAdd,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/${recipe['image'] ?? 'default_recipe.jpg'}',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['name'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Difficulty: ${recipe['difficulty']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    'Time: ${recipe['cooking_time']} mins',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                  onPressed: onAdd,
                  tooltip: 'Add to meal plan',
                ),
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, color: Colors.blue),
                  onPressed: onPreview,
                  tooltip: 'Preview recipe',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}