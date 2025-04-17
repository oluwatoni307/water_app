import 'package:flutter/material.dart';

class navBar extends StatelessWidget {
  static const List<String> routes = ['/', '/analysis', '/goals', '/settings'];
  final int currentIndex;

  const navBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex, // Highlight the current tab
      onTap: (index) {
        final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
        final newRoute = routes[index];

        // Only navigate if the new route is different from the current one
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
            label: "Analysis"),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.blueGrey),
            label: "Setting"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.blueGrey), label: "Profile"),
      ],
    );
  }
}
