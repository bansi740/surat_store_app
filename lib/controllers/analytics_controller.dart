import 'package:get/get.dart';
import '../controllers/order_controller.dart';

class AnalyticsController extends GetxController {
  final OrderController orderController = Get.find<OrderController>();

  Rx<DateTime> selectedMonth = DateTime.now().obs;
  Rxn<DateTime> selectedDate = Rxn<DateTime>();
  RxBool ascending = false.obs; // move ascending here

  RxMap<String, int> topSelling = <String, int>{}.obs;




  List get filteredOrders {
    List filtered = orderController.orderList.where((order) {
      final orderDate = order.orderDate;

      if (selectedDate.value != null) {
        return orderDate.year == selectedDate.value!.year &&
            orderDate.month == selectedDate.value!.month &&
            orderDate.day == selectedDate.value!.day;
      }

      return orderDate.year == selectedMonth.value.year &&
          orderDate.month == selectedMonth.value.month;
    }).toList();

    filtered.sort((a, b) => ascending.value
        ? a.orderDate.compareTo(b.orderDate)
        : b.orderDate.compareTo(a.orderDate));

    return filtered;
  }


  double get totalFilteredEarnings {
    return filteredOrders.fold<double>(0, (sum, order) => sum + order.totalAmount);
  }

  double get averageBuyPrice {
    if (filteredOrders.isEmpty) return 0;
    return totalFilteredEarnings / filteredOrders.length;
  }


  void changeMonth(DateTime date) {
    selectedMonth.value = DateTime(date.year, date.month);
    selectedDate.value = null;
    update();
  }

  void changeDate(DateTime date) {
    selectedDate.value = date;
    selectedMonth.value = DateTime(date.year, date.month);
    update();
  }

  void clearDateFilter() {
    selectedDate.value = null;
    update();
  }

  void toggleSort() {
    ascending.value = !ascending.value;
    update();
  }
}