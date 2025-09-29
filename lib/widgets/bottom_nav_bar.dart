import 'package:flutter/material.dart';
import 'package:vakeel_diary/Pages/add_case_page.dart';
import 'package:vakeel_diary/Pages/home_page.dart';
import 'package:vakeel_diary/Pages/list_page.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AddCasePage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ReadData()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // This Container will hold the background color for the entire nav bar area.
      color: Colors.white,
      child: SafeArea(
        // The SafeArea widget ensures its children stay within the "safe" area of the screen,
        // which pushes the content up while allowing the parent container's color to fill the space below.
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'View All',
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          onTap: (index) => _onItemTapped(context, index),
        ),
      ),
    );
  }
}