import 'package:flutter/material.dart';
import 'package:platepal/models/ingredient.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SelectedIngredientItem extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onRemove;

  const SelectedIngredientItem({
    super.key,
    required this.ingredient,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset('assets/icons/plate.svg', width: 80, height: 80),
          Image.asset(ingredient.image, width: 60, height: 60),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}