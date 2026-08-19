import 'package:flutter/material.dart';

class NavigationShell extends StatelessWidget {
  const NavigationShell({
    required this.child,
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          label: 'Explore',
        ),
        NavigationDestination(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_location_alt_outlined),
          label: 'Add Place',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          label: 'Favorites',
        ),
      ],
    ),
  );
}
