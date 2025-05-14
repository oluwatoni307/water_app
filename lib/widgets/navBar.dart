import 'package:flutter/material.dart';

class navBar extends StatelessWidget {
  static const List<String> routes = [
    '/',
    '/analysis',
    '/goals',
    '/metric',
    '/settings'
  ];
  final int currentIndex;

  const navBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final int safeIndex =
        (currentIndex >= 0 && currentIndex < routes.length) ? currentIndex : 0;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: safeIndex, // Use the safe index
      onTap: (index) {
        final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
        final newRoute = routes[index];

        if (currentRoute != newRoute) {
          Navigator.pushNamed(context, newRoute);
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.blueGrey),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart, color: Colors.blueGrey),
          label: "Analysis",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings, color: Colors.blueGrey),
          label: "Goal",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.tune, color: Colors.blueGrey),
          label: "Metrics",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: Colors.blueGrey),
          label: "Profile",
        ),
      ],
    );
  }
}
