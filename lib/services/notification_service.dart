import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/weather_model.dart';

/// Simple NotificationService that supports an in-app WhatsApp-like banner
/// and optional system notifications via flutter_local_notifications.
class NotificationService {
  NotificationService._private();
  static final NotificationService _instance = NotificationService._private();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _local.initialize(settings);
  }

  Future<void> showSystemNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'weather_chan',
      'Weather Notifications',
      channelDescription: 'Weather alerts',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const platform = NotificationDetails(android: androidDetails);
    await _local.show(id, title, body, platform);
  }

  void showInAppNotification({
    required String title,
    required String body,
    Widget? leading,
    Duration duration = const Duration(seconds: 5),
    VoidCallback? onTap,
  }) {
    try {
      showOverlayNotification((context) {
        return SafeArea(
          child: GestureDetector(
            onTap: () {
              onTap?.call();
              OverlaySupportEntry.of(context)?.dismiss();
            },
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]
                  : Colors.white,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      leading,
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            body,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: () =>
                          OverlaySupportEntry.of(context)?.dismiss(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }, duration: duration);
    } catch (e) {
      // OverlaySupport not initialized (e.g., in tests) — ignore so tests don't fail
      debugPrint('Overlay not initialized, skipping in-app notification: $e');
    }
  }

  /// Convenience: show weather as both in-app banner and system notification
  Future<void> showWeatherNotification(WeatherModel weather) async {
    final title = 'Cuaca di ${weather.locationName}';
    final body =
        '${weather.conditionText.toLowerCase()}, ${weather.tempC.round()}°C.';
    showInAppNotification(
      title: title,
      body: body,
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: Icon(
          weather.conditionText.toLowerCase().contains('rain')
              ? Icons.umbrella
              : Icons.wb_sunny,
          color: Colors.orange,
        ),
      ),
      duration: const Duration(seconds: 5),
    );
    await showSystemNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
    );
  }
}
