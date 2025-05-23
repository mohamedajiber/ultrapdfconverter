import 'package:flutter/material.dart';

class DarkModeToggle extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggle;

  const DarkModeToggle({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isDarkMode,
      onChanged: onToggle,
      activeColor: Theme.of(context).colorScheme.secondary,
    );
  }
}
