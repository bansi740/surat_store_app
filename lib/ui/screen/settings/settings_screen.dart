import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'animated_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  String selectedTheme = "System Default";
  bool notificationsEnabled = true;
  String selectedLanguage = "English";
  String syncMode = "Auto";

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

      // ================= APP BAR =================
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(30),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ),

      // ================= BODY =================
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _sectionTitle("Preferences"),

          AnimatedCard(
            index: 0,
            controller: _controller,
            child: _cardGroup([
              _tile(
                icon: Icons.dark_mode,
                color: Colors.deepPurple,
                title: "Theme",
                subtitle: selectedTheme,
                onTap: _showThemeDialog,
              ),
              _divider(),
              _tile(
                icon: Icons.language,
                color: Colors.green,
                title: "Language",
                subtitle: selectedLanguage,
                onTap: _showLanguageDialog,
              ),
            ]),
          ),

          const SizedBox(height: 16),

          _sectionTitle("System"),

          AnimatedCard(
            index: 1,
            controller: _controller,
            child: _cardGroup([
              _switchTile(),
              _divider(),
              _tile(
                icon: Icons.sync,
                color: Colors.pink,
                title: "Sync",
                subtitle: syncMode,
                onTap: _showSyncDialog,
              ),
            ]),
          ),

          const SizedBox(height: 16),

          _sectionTitle("Information"),

          AnimatedCard(
            index: 2,
            controller: _controller,
            child: _cardGroup([
              _tile(
                icon: Icons.info,
                color: Colors.blue,
                title: "About",
                subtitle: "Version 1.0.0",
                onTap: _showAboutDialog,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _cardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: Colors.grey.withAlpha(30));
  }

  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }

  Widget _switchTile() {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.orange.withAlpha(18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.notifications, color: Colors.orange),
      ),
      title: const Text(
        "Notifications",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: Switch.adaptive(
        value: notificationsEnabled,
       activeThumbColor:primaryBlue ,
        onChanged: (val) => setState(() => notificationsEnabled = val),
      ),
    );
  }

  // ================= SYNC DIALOG =================
  void _showSyncDialog() {
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
              const Row(
                children: [
                  Icon(Icons.sync, color: Colors.pink),
                  SizedBox(width: 10),
                  Text(
                    "Sync Mode",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ...["Auto", "Manual"].map((mode) {
                final isSelected = mode == syncMode;

                return GestureDetector(
                  onTap: () {
                    setState(() => syncMode = mode);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryBlue.withAlpha(40)
                          : Colors.grey.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            mode,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: primaryBlue,
                            size: 20,
                          ),
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

  // ================= LANGUAGE =================
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
              const Row(
                children: [
                  Icon(Icons.language, color: Colors.green),
                  SizedBox(width: 10),
                  Text(
                    "Select Language",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryBlue.withAlpha(40)
                          : Colors.grey.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(lang)),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: primaryBlue,
                            size: 20,
                          ),
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

  // ================= THEME =================
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
              const Row(
                children: [
                  Icon(Icons.dark_mode, color: Colors.deepPurple),
                  SizedBox(width: 10),
                  Text(
                    "Select Theme",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryBlue.withAlpha(25)
                          : Colors.grey.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(theme)),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: primaryBlue,
                            size: 20,
                          ),
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

  // ================= ABOUT =================
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
              const Row(
                children: [
                  Icon(Icons.store, color: Colors.blueAccent),
                  SizedBox(width: 10),
                  Text(
                    "About",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: primaryBlue.withAlpha(255),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}