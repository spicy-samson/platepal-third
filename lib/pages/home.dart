import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:platepal/pages/SearchByIngredientsPage.dart';
import 'package:platepal/pages/SearchByRecipePage.dart';
import 'package:platepal/pages/AccessMealPlannerPage.dart';
import 'package:platepal/components/AppBar.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showBackButton: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/platepal.svg',
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 16),
            const Text(
              'PlatePal',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchByRecipePage()),
                );
              },
              child: const Text('Search by Recipe'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchByIngredientsPage()),
                );
              },
              child: const Text('Search by Ingredients'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MealPlannerPage()),
                );
              },
              child: const Text('Access Meal Planner'),
            ),
          ],
        ),
      ),
    );
  }
}