import 'package:flutter/material.dart';
import 'package:surat_store/core/utils/assets.dart';
import 'package:surat_store/ui/screen/cart/cart_screen.dart';
import 'package:surat_store/ui/screen/home/home_screen.dart';
import 'package:surat_store/ui/screen/profile_screen/profile_screen.dart';
import '../dashboard/dashboard_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    CartScreen(),
    DashboardScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 12,
        selectedItemColor: Colors.transparent,
        unselectedItemColor: Colors.transparent,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          _navItem(
            label: 'Home',
            selectedIcon: AppAssets.homeIcon,
            unselectedIcon: AppAssets.home2Icon,
            index: 0,
          ),
          _navItem(
            label: 'Cart',
            selectedIcon: AppAssets.cart2Icon,
            unselectedIcon: AppAssets.cartIcon,
            index: 1,
          ),
          _navItem(
            label: 'Dashboard',
            selectedIcon: AppAssets.dashboardIcon,
            unselectedIcon: AppAssets.dashboard2Icon,
            index: 2,
          ),
          _navItem(
            label: 'Profile',
            selectedIcon: AppAssets.userIcon,
            unselectedIcon: AppAssets.user2Icon,
            index: 3,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem({
    required String label,
    required String selectedIcon,
    required String unselectedIcon,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAssetIcon(
            selectedIcon: selectedIcon,
            unselectedIcon: unselectedIcon,
            isSelected: isSelected,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
      label: '',
    );
  }

  Widget _buildAssetIcon({
    required String selectedIcon,
    required String unselectedIcon,
    required bool isSelected,
  }) {
    final bool isHeart =
        selectedIcon.contains("heart") || unselectedIcon.contains("heart");

    final double size = isHeart ? 26 : 22;

    Widget image = Image.asset(
      isSelected ? selectedIcon : unselectedIcon,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: isSelected ? null : Colors.black,
    );

    return AnimatedScale(
      scale: isSelected ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 350),
      child: isSelected
          ? ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xff2563EB), Color(0xff1E40AF)],
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: image,
            )
          : image,
    );
  }
}
