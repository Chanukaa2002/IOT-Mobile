import 'package:flutter/material.dart';
// Adjust this import path to point to your AppColors file
import 'package:cw_app/core/utils/app_colors.dart';

class MealBoxPage extends StatefulWidget {
  const MealBoxPage({super.key});

  @override
  State<MealBoxPage> createState() => _MealBoxPageState();
}

class _MealBoxPageState extends State<MealBoxPage> {
  // Set the initial index to 3 for the "Meal Box" tab


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // This screen has a different AppBar layout
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.grey[800]),
          onPressed: () {
            // TODO: Handle navigation back
          },
        ),
        title: Text(
          'EATRO',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.grey[800],
              size: 28,
            ),
            onPressed: () {
              // TODO: Navigate to Home
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12.0, left: 8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
            ),
          ),
        ],
      ),
      // Scrollable body content
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildMealSessionCard(),
              const SizedBox(height: 24),
              _buildAddMealTypeCard(),
            ],
          ),
        ),
      ),
      // The "sticky" bottom navigation bar
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home_outlined),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.track_changes_outlined),
      //       label: 'Goals',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.history_outlined),
      //       label: 'History',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.inventory_2_outlined),
      //       label: 'Meal Box',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: AppColors.primaryBlue,
      //   unselectedItemColor: Colors.grey[600],
      //   onTap: _onItemTapped,
      //   type: BottomNavigationBarType.fixed,
      //   showUnselectedLabels: true,
      // ),
    );
  }

  // --- Helper methods to build each card ---

  Widget _buildMealSessionCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Your partner logo asset
              Image.asset('lib/core/assets/logo.png', height: 40),
              const SizedBox(width: 12),
              const Text(
                'Your Daily Nutrition Partner',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Icon(Icons.auto_awesome_outlined, color: Colors.orange.shade400),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'No Active Meal Session',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a new meal session to begin tracking.',
            style: TextStyle(color: Colors.grey, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_circle, color: Colors.white),
            label: const Text(
              'Start New Meal',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brightBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMealTypeCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Meal Type',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'e.g., Rice,Meat,Fish...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.brightBlue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
