import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onDarkModeToggle;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: isDarkMode,
            onChanged: onDarkModeToggle,
          ),
        ],
      ),
    );
  }
}
