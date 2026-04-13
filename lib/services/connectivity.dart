import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../controllers/sync_controller.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  void startListening() {
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        final syncController = Get.find<SyncController>();

        if (!syncController.isSyncing.value) {
          syncController.syncNow();
        }
      }
    });
  }
}