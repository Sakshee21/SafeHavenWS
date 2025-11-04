import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final String currentRoute;
  final String role; // 'user', 'volunteer', 'combined'

  const BottomNav({required this.currentRoute, required this.role, super.key});

  @override
  Widget build(BuildContext context) {
    // Build the nav items based on role
    final items = <Map<String, dynamic>>[
      {'icon': Icons.home, 'label': 'Home', 'route': '/${role}_home'},
      if (role == 'user') {'icon': Icons.folder, 'label': 'My Cases', 'route': '/my_cases'},
      if (role != 'user') {'icon': Icons.folder, 'label': 'Cases', 'route': '/cases'},
      {'icon': Icons.person, 'label': 'Profile', 'route': '/profile'},
    ];

    int currentIndex = items.indexWhere((e) => e['route'] == currentRoute);
    if (currentIndex == -1) currentIndex = 0;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (idx) {
        final selected = items[idx]['route'] as String;
        if (selected != currentRoute) {
          Navigator.pushReplacementNamed(context, selected);
        }
      },
      items: items
          .map((it) => BottomNavigationBarItem(icon: Icon(it['icon']), label: it['label']))
          .toList(),
      selectedItemColor: const Color(0xFF7A28FF),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    );
  }
}
