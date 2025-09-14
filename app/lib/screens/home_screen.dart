import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'overview_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web layout with sidebar navigation
      return Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          children: [
            _buildWebSidebar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  OverviewTab(),
                  ProfileTab(),
                  SettingsTab(),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile layout with bottom navigation
      return Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        body: TabBarView(
          controller: _tabController,
          children: const [
            OverviewTab(),
            ProfileTab(),
            SettingsTab(),
          ],
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 34),
          child: _buildBottomNavigation(),
        ),
      );
    }
  }

  Widget _buildWebSidebar() {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF4FC3F7), Color(0xFFFF4081)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.park_outlined,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          _buildWebNavItem(
            icon: Icons.home_rounded,
            index: 0,
            label: 'Home',
          ),
          _buildWebNavItem(
            icon: Icons.person_rounded,
            index: 1,
            label: 'Profile',
          ),
          _buildWebNavItem(
            icon: Icons.settings_rounded,
            index: 2,
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildWebNavItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _tabController.animateTo(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected 
                ? const Color(0xFFFF4081).withOpacity(0.1)
                : Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected 
                    ? const Color(0xFFFF4081)
                    : Colors.grey[600],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isSelected 
                      ? const Color(0xFFFF4081)
                      : Colors.grey[600],
                    
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.home_rounded,
            index: 0,
            label: 'Home',
          ),
          _buildNavItem(
            icon: Icons.person_rounded,
            index: 1,
            label: 'Profile',
          ),
          _buildNavItem(
            icon: Icons.settings_rounded,
            index: 2,
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _tabController.animateTo(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected 
                      ? const Color(0xFFFF4081)
                      : Colors.transparent,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected 
                      ? Colors.white
                      : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected 
                      ? const Color(0xFFFF4081)
                      : Colors.grey[600],
                    
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}