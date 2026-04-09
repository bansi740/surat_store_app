import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surat_store/controllers/auth_controller.dart';
import '../settings/settings_screen.dart';
import 'profile_animations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final AuthController authController = Get.find();
  final Color primaryBlue = const Color(0xff2563EB);

  late AnimationController _controller;
  late ProfileAnimations animations;

  @override
  void initState() {
    super.initState();

    authController.loadUserData();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    animations = ProfileAnimations(
      controller: _controller,
      itemCount: 3, // header + 2 options
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSettingsTap() {
    Get.to(() => const SettingsScreen());
  }
  void _handleLogoutTap() {
    _showLogoutDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xffF8FAFC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER CARD ANIMATION
            SlideTransition(
              position: animations.headerSlide,
              child: FadeTransition(
                opacity: animations.headerFade,
                child: ScaleTransition(
                  scale: animations.headerScale,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: primaryBlue,
                          child: const Icon(
                            Icons.person,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authController.userName.value.isNotEmpty
                                    ? authController.userName.value
                                    : "Loading...",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authController.userEmail.value.isNotEmpty
                                    ? authController.userEmail.value
                                    : "Loading...",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // SETTINGS OPTION
            SlideTransition(
              position: animations.optionSlides[0],
              child: FadeTransition(
                opacity: animations.optionFades[0],
                child: buildProfileOption(
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  onTap: _handleSettingsTap,
                ),
              ),
            ),

            // LOGOUT OPTION
            SlideTransition(
              position: animations.optionSlides[1],
              child: FadeTransition(
                opacity: animations.optionFades[1],
                child: buildProfileOption(
                  icon: Icons.logout_outlined,
                  title: "Logout",
                  onTap: _handleLogoutTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: scale.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(18),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withAlpha(15),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Logout Account?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to logout from your shop account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text("Cancel", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          authController.logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }

  Widget buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: primaryBlue.withAlpha(20),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: primaryBlue),
        ),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}