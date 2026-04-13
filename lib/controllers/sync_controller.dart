import 'package:get/get.dart';
import '../services/sync_service.dart';
import 'auth_controller.dart';

class SyncController extends GetxController {
  late SyncService syncService;

  RxBool isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();

    final shopId = AuthController.to.currentShopId ?? '';
    syncService = SyncService(shopId);
  }

  Future<void> syncNow() async {
    try {
      isSyncing.value = true;
      await syncService.syncAll();
      Get.snackbar("Sync", "Data synced successfully");
    } catch (e) {
      Get.snackbar("Sync Error", e.toString());
    } finally {
      isSyncing.value = false;
    }
  }
}