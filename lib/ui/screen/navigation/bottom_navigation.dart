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
    const HomeScreen(),
    const CartScreen(),
    const DashboardScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Map<String, dynamic>> navItems = [
    {
      "label": "Home",
      "selected": AppAssets.homeIcon,
      "unselected": AppAssets.home2Icon,
    },
    {
      "label": "Cart",
      "selected": AppAssets.cart2Icon,
      "unselected": AppAssets.cartIcon,
    },
    {
      "label": "Dashboard",
      "selected": AppAssets.dashboardIcon,
      "unselected": AppAssets.dashboard2Icon,
    },
    {
      "label": "Profile",
      "selected": AppAssets.userIcon,
      "unselected": AppAssets.user2Icon,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _screens[_selectedIndex],
          // FLOATING NAVIGATION
          Positioned(
            left: 17,
            right: 17,
            bottom: 10,
            child: SafeArea(
              child: Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(28),
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(navItems.length, (index) {
                      final item = navItems[index];
                      final isSelected = _selectedIndex == index;

                      return GestureDetector(
                        onTap: () => _onItemTapped(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSelected ? 14 : 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xff2563EB).withAlpha(35)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              _buildAssetIcon(
                                selectedIcon: item["selected"],
                                unselectedIcon: item["unselected"],
                                isSelected: isSelected,
                                showBadge: index == 1,
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SizeTransition(
                                      sizeFactor: animation,
                                      axis: Axis.horizontal,
                                      child: child,
                                    ),
                                  );
                                },
                                child: isSelected
                                    ? Padding(
                                  key: ValueKey(item["label"]),
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    item["label"],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff2563EB),
                                    ),
                                  ),
                                )
                                    : const SizedBox(
                                  key: ValueKey("empty"),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAssetIcon({
    required String selectedIcon,
    required String unselectedIcon,
    required bool isSelected,
    bool showBadge = false,
  }) {
    Widget image = Image.asset(
      isSelected ? selectedIcon : unselectedIcon,
      width: 22,
      height: 22,
      fit: BoxFit.contain,
      color: isSelected ? null : Colors.black,
    );

    Widget finalIcon = AnimatedScale(
      scale: isSelected ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          isSelected ? const Color(0xff2563EB) : Colors.black,
          BlendMode.srcIn,
        ),
        child: image,
      ),
    );

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
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.center,
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
                      key: ValueKey<int>(count),
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