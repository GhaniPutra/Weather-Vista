import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_weather/theme/theme_provider.dart';
import '../theme/app_colors.dart';

/// Layar Pengaturan: atur tema dan akses tentang aplikasi.
class SettingsScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onAboutTap;

  /// Layar pengaturan utama untuk memilih tema dan mengakses About.
  ///
  /// - `onBack`: callback ketika tombol kembali ditekan.
  /// - `onAboutTap`: callback untuk membuka layar About.
  const SettingsScreen({
    required this.onBack,
    required this.onAboutTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.getTextColor(brightness);
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: grad),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            const SizedBox(height: 16),
            Text(
              'Theme',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: ThemeMode.values.map((mode) {
                  final isSelected = themeProvider.themeMode == mode;
                  // Tentukan label dan ikon untuk setiap opsi ThemeMode
                  final label = mode == ThemeMode.system
                      ? 'System'
                      : mode == ThemeMode.light
                          ? 'Light'
                          : 'Dark';
                  // Ikon: system -> smartphone, light -> matahari, dark -> bulan
                  final icon = mode == ThemeMode.system
                      ? Icons.smartphone
                      : mode == ThemeMode.light
                          ? Icons.wb_sunny
                          : Icons.nightlight_round;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => themeProvider.setThemeMode(mode),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 6.0),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : borderColor,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 20,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : textColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              label,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Apps',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: ListTile(
                title: Text('About', style: TextStyle(color: textColor)),
                trailing: Icon(Icons.info_outline, color: textColor),
                onTap: onAboutTap,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}
