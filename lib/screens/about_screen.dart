import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Layar About/Tentang aplikasi: menampilkan informasi versi dan keterangan proyek.
class AboutScreen extends StatelessWidget {
  final VoidCallback onBack;
  final bool isDark;

  const AboutScreen({required this.onBack, required this.isDark, super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.getTextColor(brightness);
    final secondaryTextColor = AppColors.getSecondaryTextColor(brightness);
    final cardColor = Theme.of(
      context,
    ).colorScheme.surface; // use theme surface
    const dividerColor = Color.fromARGB(255, 200, 200, 200);

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
      // use container gradient so scaffold background can remain transparent in Theme
      body: Container(
        decoration: BoxDecoration(gradient: grad),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: onBack,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Tentang Aplikasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Simple Weather App',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Versi 1.0.0',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Aplikasi ini dikembangkan sebagai proyek implementasi untuk mata kuliah Mobile & Web Service.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tujuan utama dari pengembangan aplikasi ini adalah untuk mendemonstrasikan penerapan teknologi Mobile Development yang terintegrasi dengan layanan Web Service (REST API).',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aplikasi ini mengambil data cuaca secara real-time dan menyajikannya dalam antarmuka pengguna yang responsif.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Divider(color: dividerColor),
                          const SizedBox(height: 16),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Fakultas Sains & Teknologi',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Universitas Teknologi Yogyakarta',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '2025',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
