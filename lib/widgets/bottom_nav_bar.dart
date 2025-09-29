import 'package:flutter/material.dart';
import 'package:vakeel_diary/Pages/add_case_page.dart';
import 'package:vakeel_diary/Pages/home_page.dart';
import 'package:vakeel_diary/Pages/list_page.dart';

// --- THEME COLORS (for consistency) ---
const Color primaryBlue = Color(0xFF1A237E);
const Color offWhite = Color(0xFFF5F5F5);
const Color darkGray = Color(0xFF424242);

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const AddCasePage();
        break;
      case 2:
        page = const ReadData();
        break;
      default:
        return;
    }

    // Use PageRouteBuilder for a smooth fade-in transition
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: offWhite,
      elevation: 0,
      child: SizedBox(
        height: kBottomNavigationBarHeight,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(context, Icons.home_outlined, 'Home', 0),
                _buildNavItem(context, Icons.add_circle_outline, 'Add', 1),
                _buildNavItem(context, Icons.view_list_outlined, 'View All', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final Color iconColor = selectedIndex == index ? primaryBlue : darkGray;
    final FontWeight fontWeight = selectedIndex == index
        ? FontWeight.bold
        : FontWeight.normal;

    return InkWell(
      onTap: () => _onItemTapped(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: iconColor,
              fontSize: 11,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}
