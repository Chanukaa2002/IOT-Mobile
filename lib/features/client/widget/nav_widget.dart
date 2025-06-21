import 'package:flutter/material.dart';
import 'package:cw_app/features/client/pages/home_page.dart';
import 'package:cw_app/features/client/pages/goal_page.dart';
import 'package:cw_app/features/client/pages/history_page.dart';
import 'package:cw_app/features/client/pages/meal_box_page.dart';
import 'package:cw_app/core/utils/app_colors.dart';
import 'package:cw_app/features/client/widget/custom_app_bar.dart';
import 'package:cw_app/features/client/widget/custom_drawer.dart';

class NavWidget extends StatefulWidget {
  const NavWidget({super.key});

  @override
  State<NavWidget> createState() => _NavWidgetState();
}

class _NavWidgetState extends State<NavWidget> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    GoalsPage(),
    HistoryPage(),
    MealBoxPage(),
  ];

  static const List<String> _pageTitles = <String>[
    'EATRO',
    'Your Goals',
    'Nutritional History',
    'Meal Box',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _pageTitles[_selectedIndex],
      ),
      drawer: const CustomDrawer(),

      body: _pages.elementAt(_selectedIndex),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes_outlined),
            activeIcon: Icon(Icons.track_changes),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
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
