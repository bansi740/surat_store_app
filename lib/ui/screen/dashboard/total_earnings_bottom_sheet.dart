import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/analytics_controller.dart';
import '../../../core/utils/app_formatter.dart';
import 'total_earnings_animations.dart';

class TotalEarningsBottomSheet extends StatefulWidget {
  const TotalEarningsBottomSheet({super.key});

  @override
  State<TotalEarningsBottomSheet> createState() =>
      _TotalEarningsBottomSheetState();
}

class _TotalEarningsBottomSheetState extends State<TotalEarningsBottomSheet>
    with SingleTickerProviderStateMixin {
  final AnalyticsController analyticsController =
  Get.put(AnalyticsController());

  late AnimationController _controller;
  late TotalEarningsAnimations animations;

  final Color primaryBlue = const Color(0xff2563EB);


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    animations = TotalEarningsAnimations(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: analyticsController.selectedMonth.value,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      analyticsController.changeMonth(picked);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: analyticsController.selectedDate.value ??
          analyticsController.selectedMonth.value,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      analyticsController.changeDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animations.slideUp,
      child: FadeTransition(
        opacity: animations.fade,
        child: ScaleTransition(
          scale: animations.scale,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.95,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xffF8FAFC),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: GetBuilder<AnalyticsController>(
              builder: (controller) {
                final filtered = controller.filteredOrders;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // name
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryBlue.withAlpha(20),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.analytics_rounded,
                            color: primaryBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Earnings Dashboard",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    //  Filter Buttons
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryBlue.withAlpha(25),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: primaryBlue.withAlpha(35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Month Button
                          Expanded(
                            child: InkWell(
                              onTap: _pickMonth,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withAlpha(12),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: primaryBlue.withAlpha(35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_month_rounded,
                                      color: primaryBlue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('MMM yyyy')
                                          .format(controller.selectedMonth.value),
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Date Button
                          Expanded(
                            child: InkWell(
                              onTap: _pickDate,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: controller.selectedDate.value != null
                                      ? Colors.green.withAlpha(12)
                                      : primaryBlue.withAlpha(8),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: controller.selectedDate.value != null
                                        ? Colors.green.withAlpha(35)
                                        : primaryBlue.withAlpha(35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.date_range_rounded,
                                      color: controller.selectedDate.value != null
                                          ? Colors.green
                                          : primaryBlue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        controller.selectedDate.value == null
                                            ? "Pick Date"
                                            : DateFormat('dd MMM')
                                            .format(controller.selectedDate.value!),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: controller.selectedDate.value != null
                                              ? Colors.green
                                              : primaryBlue,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (controller.selectedDate.value != null) ...[
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: controller.clearDateFilter,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(10),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.red.withAlpha(25),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildPremiumCard(
                      title: "Total Earnings",
                      value: AppFormatter.formatPrice(
                        controller.totalFilteredEarnings,
                      ),
                      icon: Icons.account_balance_wallet_rounded,
                      colors: const [
                        Color(0xff16A34A),
                        Color(0xff22C55E),
                      ],
                      fullWidth: true,
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _buildSmallPremiumCard(
                            title: "Orders",
                            value: filtered.length.toString(),
                            icon: Icons.shopping_bag_rounded,
                            colors: const [
                              Color(0xffF97316),
                              Color(0xffFB923C),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSmallPremiumCard(
                            title: "Avg Price",
                            value: AppFormatter.formatPrice(
                              controller.averageBuyPrice,
                            ),
                            icon: Icons.trending_up_rounded,
                            colors: const [
                              Color(0xff2563EB),
                              Color(0xff3B82F6),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Filtered Order History",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Obx(() {
                          final controller = analyticsController;
                          return InkWell(
                            onTap: controller.toggleSort,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: primaryBlue.withAlpha(12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: primaryBlue.withAlpha(25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedRotation(
                                    turns: controller.ascending.value ? 0 : 0.5,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 18,
                                      color: primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    controller.ascending.value
                                        ? "Ascending"
                                        : "Descending",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: filtered.isEmpty
                          ? FadeTransition(
                        opacity: animations.fade,
                        child: Center(
                          child: Text(
                            "No orders found",
                            style: TextStyle(
                              fontSize: 15,
                              color: primaryBlue.withAlpha(140),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                          : ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final order = filtered[index];

                          final itemAnimation = Tween<Offset>(
                            begin: const Offset(0, 0.08),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _controller,
                              curve: Interval(
                                0.1 + (index * 0.05).clamp(0.0, 0.6),
                                0.8,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          );

                          final fadeAnimation = Tween<double>(
                            begin: 0,
                            end: 1,
                          ).animate(
                            CurvedAnimation(
                              parent: _controller,
                              curve: Interval(
                                0.05 + (index * 0.05).clamp(0.0, 0.6),
                                0.75,
                                curve: Curves.easeInOut,
                              ),
                            ),
                          );

                          return SlideTransition(
                            position: itemAnimation,
                            child: FadeTransition(
                              opacity: fadeAnimation,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withAlpha(8),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: primaryBlue.withAlpha(18),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.customerName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xff0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat('dd MMM yyyy')
                                                .format(order.orderDate),
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ScaleTransition(
                                      scale: animations.refreshPulse,
                                      child: Text(
                                        AppFormatter.formatPrice(
                                          order.totalAmount,
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> colors,
    bool fullWidth = false,
  }) {
    final Color primary = colors.first;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary.withAlpha(25),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: primary.withAlpha(35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: primary.withAlpha(35),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallPremiumCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> colors,
  }) {
    final Color primary = colors.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withAlpha(25),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: primary.withAlpha(35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primary.withAlpha(35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: primary, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}