import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:platepal/pages/SearchByIngredientsPage.dart';
import 'package:platepal/pages/SearchByRecipePage.dart';
import 'package:platepal/pages/AccessMealPlannerPage.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
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
  AppBar appbar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/platepal.svg',
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 8), // Spacing between the icon and text
          const Text(
            'PlatePal',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: const Color(0xffF7F8F8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: SvgPicture.asset(
            'assets/icons/arrow-left.svg',
            height: 24,
            width: 24,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }
}
