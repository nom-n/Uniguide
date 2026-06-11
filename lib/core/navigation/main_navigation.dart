import 'package:flutter/material.dart';
import 'package:uniguide/features/guides/guides_page.dart';
import 'package:uniguide/features/home/home_page.dart';
import 'package:uniguide/features/profile/profile_page.dart';
import 'package:uniguide/features/tasks/tasks_page.dart';
import 'package:uniguide/l10n/app_localizations.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final List<Widget> pages = [
    HomePage(),
    TasksPage(),
    GuidesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF007AFF),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: lang.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_circle),
            label: lang.tasks,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book),
            label: lang.guides,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: lang.profile,
          ),
        ],
      ),
    );
  }
}

