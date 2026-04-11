import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surat_store/core/utils/assets.dart';
import 'package:surat_store/ui/screen/cart/cart_screen.dart';
import 'package:surat_store/ui/screen/home/home_screen.dart';
import 'package:surat_store/ui/screen/profile_screen/profile_screen.dart';
import '../../../controllers/cart_controller.dart';
import '../dashboard/dashboard_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final cartController = Get.find<CartController>();

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
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: SizedBox(
          height: 78,
          child: BottomNavigationBar(
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
        ),
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
            showBadge: index == 1, //  badge only for cart
          ),
          const SizedBox(height: 2),
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
    bool showBadge = false,
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

    Widget finalIcon = AnimatedScale(
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

    // ================= CART BADGE =================
    if (showBadge) {
      return Obx(() {
        final count = cartController.cartItems.length;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            finalIcon,
            if (count > 0)
              Positioned(
                right: -8,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      count > 99 ? "99+" : "$count",
                      key: ValueKey<int>(count), // IMPORTANT for animation trigger
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      });
    }

    return finalIcon;
  }
}