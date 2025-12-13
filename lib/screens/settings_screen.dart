import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onBack;
  final VoidCallback onAboutTap;

  const SettingsScreen({
    required this.isDark,
    required this.onThemeChanged,
    required this.onBack,
    required this.onAboutTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.getTextColor(brightness);
    final secondaryTextColor = AppColors.getSecondaryTextColor(brightness);
    final borderColor = AppColors.getBorderColor(brightness);
    final cardColor = Theme.of(context).colorScheme.surface;

    final lightGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFDFF6FA), Color(0xFFF6E8DA)],
    );
    final darkGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0F0F0F), Color(0xFF1B1B1B)],
    );
    final grad = brightness == Brightness.dark ? darkGradient : lightGradient;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: grad),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: onBack),
                    Expanded(
                      child: Center(
                        child: Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Apps', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Theme', style: TextStyle(color: textColor)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => onThemeChanged(true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: borderColor.withAlpha((0.3 * 255).round())),
                                ),
                                child: Text('Dark', style: TextStyle(color: isDark ? Colors.white : secondaryTextColor)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => onThemeChanged(false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: !isDark ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: borderColor.withAlpha((0.3 * 255).round())),
                                ),
                                child: Text('Light', style: TextStyle(color: !isDark ? Colors.white : secondaryTextColor)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: borderColor),
                      ListTile(
                        title: Text('About', style: TextStyle(color: textColor)),
                        trailing: Icon(Icons.info_outline, color: textColor),
                        onTap: onAboutTap,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
