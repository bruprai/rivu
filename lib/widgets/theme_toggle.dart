// lib/widgets/theme_toggle.dart - FIXED Clickable Dropdown
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../core/colors.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final currentMode = themeProvider.themeMode;

        return PopupMenuButton<ThemeMode>(
          icon: _buildToggleIcon(currentMode, context),
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
          ),
          elevation: 8,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          enabled: true, // ✅ Always enabled
          itemBuilder: (context) => [
            // Light Theme - ✅ FIXED: enabled: true
            PopupMenuItem(
              value: ThemeMode.light,
              enabled: true, // ✅ Always clickable
              child: Row(
                children: [
                  Icon(Icons.light_mode, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Text('Light'),
                  const Spacer(),
                  if (currentMode == ThemeMode.light)
                    Icon(Icons.check, color: AppColors.success, size: 20),
                ],
              ),
            ),
            // Dark Theme - ✅ FIXED: enabled: true
            PopupMenuItem(
              value: ThemeMode.dark,
              enabled: true, // ✅ Always clickable
              child: Row(
                children: [
                  Icon(Icons.dark_mode, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Text('Dark'),
                  const Spacer(),
                  if (currentMode == ThemeMode.dark)
                    Icon(Icons.check, color: AppColors.success, size: 20),
                ],
              ),
            ),
            const PopupMenuDivider(),
            // System Theme - Pre-selected
            PopupMenuItem(
              value: ThemeMode.system,
              enabled: true, // ✅ Always clickable
              child: Row(
                children: [
                  Icon(Icons.brightness_auto, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Text('System'),
                  const Spacer(),
                  if (currentMode == ThemeMode.system)
                    Icon(Icons.check, color: AppColors.success, size: 20),
                ],
              ),
            ),
          ],
          onSelected: (ThemeMode mode) {
            ScaffoldMessenger.of(context).clearSnackBars();
            themeProvider.setTheme(mode);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Theme: ${mode.name.toUpperCase()}'),
                backgroundColor: AppColors.primary,
                duration: const Duration(milliseconds: 1200),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildToggleIcon(ThemeMode mode, BuildContext context) {
    IconData icon;
    switch (mode) {
      case ThemeMode.light:
        icon = Icons.light_mode;
        break;
      case ThemeMode.dark:
        icon = Icons.dark_mode;
        break;
      case ThemeMode.system:
      default:
        icon = Icons.brightness_auto;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.glassLight.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }
}
