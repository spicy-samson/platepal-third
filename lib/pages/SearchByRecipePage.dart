import 'package:flutter/material.dart';

class SearchByRecipePage extends StatelessWidget {
  const SearchByRecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search by Recipe')),
      body: const Center(child: Text('Search by Recipe Page')),
    );
  }
}
