import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
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
        destinations: destinations
            .map((destination) => NavigationDestination(
                  icon: _NavIcon(icon: destination.icon, selected: false),
                  selectedIcon:
                      _NavIcon(icon: destination.icon, selected: true),
                  label: destination.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;

  const _NavIcon({required this.icon, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: selected ? AppColors.primary : AppColors.navInactive,
        ),
        const SizedBox(height: 3),
        Container(
          width: 14,
          height: 2,
          color: selected ? AppColors.accent : Colors.transparent,
        ),
      ],
    );
  }
}
