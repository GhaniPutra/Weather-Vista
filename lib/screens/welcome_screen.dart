import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  const WelcomeScreen({required this.onGetStarted, super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sama seperti gradient di main.dart
    final lightGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFDFF6FA), Color(0xFFF6E8DA)],
    );

    final darkGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0E0E0E), Color(0xFF1A1A1A)],
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark ? darkGradient : lightGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.08),

              /// ⭐ ICON GAMBAR PNG
              Center(
                child: SizedBox(
                  width: size.width * 0.55,
                  child: Image.asset(
                    "assets/images/sun_cloud.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.06),

              /// Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      'WEATHER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF22343D),
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'VSTA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF22343D),
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.03),

              /// Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Stay prepared with real-time\nweather updates for your day.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : const Color(0xFF50606A),
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(),

              /// Get Started button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white
                          : const Color(0xFF22343D),
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onGetStarted,
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 16),
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
