import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cw_app/main.dart';
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

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print("NavWidget initialized, starting goal monitoring...");
      goalMonitorService.startMonitoring(user.uid);
    }
  }

  @override
  void dispose() {
    print("NavWidget disposed, stopping goal monitoring...");
    goalMonitorService.stopMonitoring();
    super.dispose();
  }

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
    final List<Widget> pages = [
      HomePage(),
      const GoalsPage(),
      const HistoryPage(),
      const MealBoxPage(),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: _pageTitles[_selectedIndex],
      ),
      drawer: const CustomDrawer(),
      body: pages.elementAt(_selectedIndex),
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