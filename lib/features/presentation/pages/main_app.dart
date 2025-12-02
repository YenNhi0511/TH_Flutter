import 'package:flutter/material.dart';
import 'package:mangxahoi/features/posts/presentation/widgets/enhanced_feed_page.dart';
import 'package:mangxahoi/features/posts/presentation/pages/instagram_camera_page.dart';
import 'package:mangxahoi/features/auth/presentation/pages/search_page.dart';
import 'package:mangxahoi/features/auth/presentation/pages/modern_profile_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const EnhancedFeedPage(), // Home feed
    const SearchPage(), // Search
    const InstagramCameraPage(), // Create post
    const SearchPage(), // Notifications (placeholder)
    const ModernProfilePage(), // Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[300]!, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 28),
              activeIcon: Icon(Icons.home, size: 28),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 28),
              activeIcon: Icon(Icons.search, size: 28),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined, size: 28),
              activeIcon: Icon(Icons.add_box, size: 28),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border, size: 28),
              activeIcon: Icon(Icons.favorite, size: 28),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 28),
              activeIcon: Icon(Icons.person, size: 28),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
