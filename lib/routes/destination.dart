import 'package:flutter/material.dart';

class Destination {
  final String label;
  final IconData icon;

  Destination({
    required this.label,
    required this.icon,
  });
}

final destinations = [
  Destination(label: 'Ulubione', icon: Icons.favorite),
  Destination(label: 'Zamrażarka', icon: Icons.ac_unit),
  Destination(label: 'Start', icon: Icons.home),
  Destination(label: 'Zakupy', icon: Icons.shopping_cart),
];