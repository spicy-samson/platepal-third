import 'package:flutter/material.dart';

class SearchByIngredientsPage extends StatelessWidget {
  const SearchByIngredientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search by Ingredients')),
      body: const Center(child: Text('Search by Ingredients Page')),
    );
  }
}
