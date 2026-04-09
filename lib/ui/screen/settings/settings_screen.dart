import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/assets.dart';
import 'animated_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  String selectedTheme = "System Default";
  bool notificationsEnabled = true;
  String selectedLanguage = "English";

  final Color primaryBlue = const Color(0xff2563EB);
  final Color bgColor = const Color(0xffF8FAFC);

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
        ),
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
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AnimatedCard(
            index: 0,
            controller: _controller,
            child: _buildCardTile(
              icon: Icons.dark_mode,
              iconColor: Colors.deepPurple,
              title: "Theme",
              subtitle: selectedTheme,
              onTap: _showThemeDialog,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedCard(
            index: 1,
            controller: _controller,
            child: _buildCardTile(
              icon: Icons.notifications,
              iconColor: Colors.orange,
              title: "Notifications",
              trailing: Switch.adaptive(
                value: notificationsEnabled,
                activeThumbColor: primaryBlue,
                onChanged: (val) => setState(() => notificationsEnabled = val),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedCard(
            index: 2,
            controller: _controller,
            child: _buildCardTile(
              icon: Icons.language,
              iconColor: Colors.green,
              title: "Language",
              subtitle: selectedLanguage,
              onTap: _showLanguageDialog,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedCard(
            index: 3,
            controller: _controller,
            child: _buildCardTile(
              icon: Icons.info,
              iconColor: Colors.blueAccent,
              title: "About",
              subtitle: "Version 1.0.0",
              onTap: _showAboutDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: Colors.black.withAlpha(18),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(30),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey[600])) : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(245),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: const [
                  Icon(Icons.language, color: Colors.green),
                  SizedBox(width: 10),
                  Text(
                    "Select Language",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...["English", "Hindi", "Gujarati"].map((lang) {
                final isSelected = lang == selectedLanguage;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedLanguage = lang);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryBlue.withAlpha(40)
                          : Colors.grey.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(lang, style: const TextStyle(fontSize: 16))),
                        if (isSelected)
                          Icon(Icons.check_circle, color: primaryBlue.withAlpha(255), size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(245),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: const [
                  Icon(Icons.dark_mode, color: Colors.deepPurple),
                  SizedBox(width: 10),
                  Text(
                    "Select Theme",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...["System Default", "Light", "Dark"].map((theme) {
                final isSelected = theme == selectedTheme;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedTheme = theme);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryBlue.withAlpha(25)
                          : Colors.grey.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(theme, style: const TextStyle(fontSize: 16))),
                        if (isSelected)
                          Icon(Icons.check_circle, color: primaryBlue.withAlpha(255), size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(245),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: const [
                  Icon(Icons.store, color: Colors.blueAccent),
                  SizedBox(width: 10),
                  Text(
                    "About",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Surat Store\nVersion 1.0.0\n\nThis is a demo store app built with Flutter & GetX.",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close", style: TextStyle(color: primaryBlue.withAlpha(255))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}