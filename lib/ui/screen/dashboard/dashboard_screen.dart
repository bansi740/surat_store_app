import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:surat_store/ui/screen/dashboard/total_earnings_bottom_sheet.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/order_controller.dart';
import '../../../controllers/product_controller.dart';
import '../inventory/inventory_screen.dart';
import '../orders/order_screen.dart';
import '../products/add_product_screen.dart';
import 'dashboard_animations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late DashboardAnimations _animations;
  final ProductController productController = Get.find<ProductController>();
  final OrderController orderController = Get.find<OrderController>();
  final AuthController authController = Get.find();

  final Color primaryBlue = const Color(0xff2563EB);


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animations = DashboardAnimations(controller: _controller);
    if (authController.userName.value.isEmpty) {
      authController.loadUserData().then((_) => _controller.forward());
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FB),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 18, right: 18, top: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                SlideTransition(
                  position: _animations.welcomeOffset,
                  child: FadeTransition(
                    opacity: _animations.welcomeFade,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff2563EB), Color(0xff1E40AF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Welcome Back,",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(
                                  () => Text(
                                    authController.userName.value.isNotEmpty
                                        ? authController.userName.value
                                        : "Loading...",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Manage your store efficiently",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withAlpha(220),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white.withAlpha(40),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Stats
                SlideTransition(
                  position: _animations.statsOffset,
                  child: FadeTransition(
                    opacity: _animations.statsFade,
                    child: Obx(
                      () => Row(
                        children: [
                          _buildStatCard(
                            "${productController.productList.length}",
                            "Products",
                            Icons.inventory_2,
                          ),
                          const SizedBox(width: 14),
                          _buildStatCard(
                            "${orderController.orderList.length}",
                            "Orders",
                            Icons.shopping_bag,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Quick Actions Title
                SlideTransition(
                  position: _animations.quickTitleOffset,
                  child: FadeTransition(
                    opacity: _animations.quickTitleFade,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Quick Actions",
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Action Cards (individual)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.1,
                          children: [
                            SlideTransition(
                              position: _animations.addProductOffset,
                              child: FadeTransition(
                                opacity: _animations.addProductFade,
                                child: _buildDashboardGridCard(
                                  title: "Add Product",
                                  subtitle: "Create item",
                                  icon: Icons.add_box_rounded,
                                  color: const Color(0xff6366F1),
                                  onTap: () => Get.to(AddProductScreen()),
                                ),
                              ),
                            ),

                            SlideTransition(
                              position: _animations.inventoryOffset,
                              child: FadeTransition(
                                opacity: _animations.inventoryFade,
                                child: _buildDashboardGridCard(
                                  title: "Inventory",
                                  subtitle: "Manage stock",
                                  icon: Icons.inventory_2_rounded,
                                  color: const Color(0xffF59E0B),
                                  onTap: () => Get.to(InventoryScreen()),
                                ),
                              ),
                            ),

                            SlideTransition(
                              position: _animations.ordersOffset,
                              child: FadeTransition(
                                opacity: _animations.ordersFade,
                                child: _buildDashboardGridCard(
                                  title: "Orders",
                                  subtitle: "Track orders",
                                  icon: Icons.shopping_bag_rounded,
                                  color: const Color(0xff10B981),
                                  onTap: () => Get.to(OrdersScreen()),
                                ),
                              ),
                            ),

                            SlideTransition(
                              position: _animations.reportsOffset,
                              child: FadeTransition(
                                opacity: _animations.reportsFade,
                                child: _buildDashboardGridCard(
                                  title: "Earnings",
                                  subtitle: "View report",
                                  icon: Icons.analytics_rounded,
                                  color: const Color(0xff2563EB),
                                  onTap: () {
                                    Get.bottomSheet(
                                      const TotalEarningsBottomSheet(),
                                      isScrollControlled: true,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  static Widget _buildStatCard(String value, String title, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xff2563EB).withAlpha(40),
                    const Color(0xff2563EB).withAlpha(30),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(
                  icon, // updated icon passed from caller
                  color: const Color(0xff2563EB),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardGridCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: color.withAlpha(18),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
