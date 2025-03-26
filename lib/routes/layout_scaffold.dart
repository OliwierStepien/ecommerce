import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/routes/destination.dart';

class LayoutScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const LayoutScaffold({required this.navigationShell, Key? key})
      : super(key: key ?? const ValueKey<String>('LayoutScaffold'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        indicatorColor: Theme.of(context).primaryColor,
        destinations: destinations
            .map((destination) => NavigationDestination(
                  icon: Icon(destination.icon),
                  label: destination.label,
                  selectedIcon: Icon(
                    destination.icon,
                    color: Colors.white,
                  ),
                ))
            .toList(),
      ),
    );
  }
}
