import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ui/screen/auth/login_screen.dart';
import '../ui/screen/auth/register_screen.dart';
import '../ui/screen/navigation/bottom_navigation.dart';
import 'cart_controller.dart';
import 'order_controller.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;

  RxString prefillEmail = ''.obs;
  RxString prefillPassword = ''.obs;

  RxString userName = ''.obs;
  RxString userEmail = ''.obs;

  String? get currentShopId => _auth.currentUser?.uid;

  // ================= REGISTER =================
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final shopId = userCredential.user!.uid;

      await _firestore.collection('users').doc(shopId).set({
        'shop_id': shopId,
        'name': name,
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('shop_id', shopId);

      prefillEmail.value = '';
      prefillPassword.value = '';

      await loadUserData();

      //  START USER BASED ORDER LISTENER
      if (Get.isRegistered<OrderController>()) {
        Get.find<OrderController>().startListeningOrders();
      }

      if (Get.isRegistered<CartController>()) {
        await Get.find<CartController>().loadCartFromDb();
      }

      Get.find<CartController>().loadCartFromDb();

      Get.offAll(() => const BottomNavigation());

      Get.snackbar(
        "Success",
        "Account created successfully",
        snackPosition: SnackPosition.TOP,
      );
    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong";

      if (e.code == 'email-already-in-use') {
        message = "This email is already registered";
      } else if (e.code == 'weak-password') {
        message = "Password is too weak";
      }

      Get.snackbar(
        "Register Failed",
        message,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ================= LOGIN =================
  Future<void> login({required String email, required String password}) async {
    try {
      isLoading.value = true;

      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        Get.snackbar(
          "Account Not Found",
          "Please create a new account",
          snackPosition: SnackPosition.TOP,
        );

        prefillEmail.value = email;
        prefillPassword.value = password;

        Get.to(() => const RegisterScreen());
        return;
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('shop_id', userCredential.user!.uid);

      await loadUserData();

      // START USER BASED ORDER LISTENER
      if (Get.isRegistered<OrderController>()) {
        Get.find<OrderController>().startListeningOrders();
      }

      if (Get.isRegistered<CartController>()) {
        await Get.find<CartController>().loadCartFromDb();
      }

      Get.find<CartController>().loadCartFromDb();

      Get.offAll(() => const BottomNavigation());

      Get.snackbar(
        "Success",
        "Login successful",
        snackPosition: SnackPosition.TOP,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        Get.snackbar(
          "Login Failed",
          "Wrong password. Please try again",
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          "Login Failed",
          e.message ?? "Something went wrong",
          snackPosition: SnackPosition.TOP,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    // CLEAR USER BASED ORDERS
    if (Get.isRegistered<OrderController>()) {
      Get.find<OrderController>().clearOrders();
    }

    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().cartItems.clear();
    }

    await _auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    userName.value = '';
    userEmail.value = '';

    Get.offAll(() => const LoginScreen());

    Get.snackbar(
      "Logout",
      "Logged out successfully",
      snackPosition: SnackPosition.TOP,
    );
  }

  // ================= SHARED PREF CHECK =================
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // ================= LOAD USER DATA =================
  Future<void> loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          userName.value = doc['name'] ?? '';
          userEmail.value = doc['email'] ?? '';

          // Save to local cache
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_name', userName.value);
          await prefs.setString('user_email', userEmail.value);
        }
      } catch (e) {
        print("Failed to load user data: $e");
      }
    }
  }
}
