import 'package:flutter/material.dart';

class ListByCategoriesHeader extends StatelessWidget {
  const ListByCategoriesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Wszystkie kategorie',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
    );
  }
}
