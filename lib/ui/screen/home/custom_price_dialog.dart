import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/product_controller.dart';

class CustomPriceDialog extends StatefulWidget {
  final Function(double min, double max) onApply;

  const CustomPriceDialog({
    super.key,
    required this.onApply,
  });

  @override
  State<CustomPriceDialog> createState() => _CustomPriceDialogState();
}

class _CustomPriceDialogState extends State<CustomPriceDialog> {
  final ProductController controller = Get.find<ProductController>();

  final Color primaryBlue = const Color(0xff2563EB);
  final Color darkBlue = const Color(0xff1E40AF);

  late RangeValues _currentRange;

  int get sliderDivisions {
    final range =
        controller.defaultMaxPrice - controller.defaultMinPrice;

    return (range / 50).clamp(20, 300).toInt();
  }

  @override
  void initState() {
    super.initState();

    _currentRange = RangeValues(
      controller.minPrice,
      controller.maxPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Price Filter",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff0F172A),
              ),
            ),
            const SizedBox(height: 6),

            Text(
              "Choose your price range",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _buildPriceBox(
                    title: "Min",
                    value: _currentRange.start.toInt(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPriceBox(
                    title: "Max",
                    value: _currentRange.end.toInt(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            RangeSlider(
              values: _currentRange,
              min: controller.defaultMinPrice,
              max: controller.defaultMaxPrice,
              divisions: sliderDivisions,
              labels: RangeLabels(
                "₹${_currentRange.start.toInt()}",
                "₹${_currentRange.end.toInt()}",
              ),
              activeColor: primaryBlue,
              inactiveColor: primaryBlue.withAlpha(35),
              onChanged: (values) {
                setState(() {
                  _currentRange = values;
                });
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue, darkBlue],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(
                          _currentRange.start,
                          _currentRange.end,
                        );
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Apply",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBox({
    required String title,
    required int value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "₹$value",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}