import 'package:flutter/material.dart';
import 'package:cw_app/features/client/pages/home_page.dart';
import 'package:cw_app/features/client/pages/goal_page.dart';
import 'package:cw_app/features/client/pages/history_page.dart';
import 'package:cw_app/features/client/pages/meal_box_page.dart';
import 'package:cw_app/core/utils/app_colors.dart';

class NavWidget extends StatefulWidget {
  const NavWidget({super.key});

  @override
  State<NavWidget> createState() => _NavWidgetState();
}

class _NavWidgetState extends State<NavWidget> {
  // The index of the currently selected page
  int _selectedIndex = 0;

  // The list of pages to be displayed
  static const List<Widget> _pages = <Widget>[
    HomePage(),
    GoalsPage(),
    HistoryPage(),
    MealBoxPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body will now switch between the pages in our list
      body: _pages.elementAt(_selectedIndex),

      // The BottomNavigationBar is defined ONCE here
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Goals',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Meal Box',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
