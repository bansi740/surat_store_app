import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../controllers/order_controller.dart';
import '../../../../core/utils/app_formatter.dart';
import '../../../../core/utils/assets.dart';
import '../../../../data/model/order_model.dart';
import 'orders_animations.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  final OrderController orderController = Get.find<OrderController>();
  final DateFormat orderDateFormat = DateFormat('yyyy-MM-dd hh:mm a');

  final Color primaryBlue = const Color(0xff2563EB);
  final Color accentGreen = const Color(0xff16A34A);

  late AnimationController _animationController;
  OrdersAnimations? _ordersAnimations;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getSectionTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return "Today";
    if (diff == 1) return "Yesterday";
    if (diff < 7) return DateFormat('EEEE').format(date);

    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0, // scroll to top
                duration: const Duration(milliseconds: 500), // smooth duration
                curve: Curves.easeOutCubic, // natural deceleration
              );
            }
          },
          child: const Text(
            "Your Orders",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        surfaceTintColor: primaryBlue,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Get.back(),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(30),
              border: Border.all(color: Colors.white.withAlpha(50), width: 1),
            ),
            child: Center(
              child: Image.asset(
                AppAssets.backIcon,
                width: 22,
                height: 22,
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderController.getUserOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading orders: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: primaryBlue.withAlpha(10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 42,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "No orders yet",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Your latest customer orders will appear here",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          // Latest first
          orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

          _ordersAnimations = OrdersAnimations(
            controller: _animationController,
            itemCount: orders.length,
          );

          _animationController.forward(from: 0);

          return ListView.builder(
            controller: _scrollController, // add this
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final currentTitle = _getSectionTitle(order.orderDate);

              final previousTitle = index == 0
                  ? ""
                  : _getSectionTitle(orders[index - 1].orderDate);

              final showHeader = index == 0 || currentTitle != previousTitle;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader)
                    _buildSectionHeader(
                      currentTitle,
                      index,
                      _animationController,
                    ),
                  SizedBox(height: 5),
                  FadeTransition(
                    opacity: _ordersAnimations!.fadeAnimations[index],
                    child: SlideTransition(
                      position: _ordersAnimations!.slideAnimations[index],
                      child: ScaleTransition(
                        scale: _ordersAnimations!.scaleAnimations[index],
                        child: _buildOrderCard(order),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue.withAlpha(18), primaryBlue.withAlpha(8)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Order ID:${order.id ?? 'N/A'}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppFormatter.formatPrice(order.totalAmount),
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: accentGreen,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        orderDateFormat.format(order.orderDate.toLocal()),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    int index,
    AnimationController controller,
  ) {
    // Optimized slide & fade animations
    final slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.12), // subtle vertical offset
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              (index * 0.06).clamp(0.0, 1.0),
              // faster stagger for better performance
              ((index * 0.06) + 0.35).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        );

    final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          (index * 0.06).clamp(0.0, 1.0),
          ((index * 0.06) + 0.35).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      ),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              // slightly smaller pill
              decoration: BoxDecoration(
                color: primaryBlue.withAlpha(12), // subtle background
                borderRadius: BorderRadius.circular(40), // smaller radius
                border: Border.all(color: primaryBlue.withAlpha(20), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withAlpha(6),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20, // slightly smaller icon circle
                    decoration: BoxDecoration(
                      color: primaryBlue.withAlpha(18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      // smaller text for compact pill
                      fontWeight: FontWeight.w600,
                      // lighter weight for modern feel
                      color: const Color(0xff1E293B),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
