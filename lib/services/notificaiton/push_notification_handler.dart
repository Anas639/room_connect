import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationHandler {
  AndroidNotificationChannel? _channel;
  _setupAndroidChannel(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    _channel = const AndroidNotificationChannel(
      "fcm_push",
      "Push Notificaiton",
      description: "This channel is to receive push notificaitons",
      importance: Importance.high,
      enableLights: true,
      enableVibration: true,
    );
    const androidSettings = AndroidInitializationSettings("@mipmap/ic_launcher");
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await plugin.initialize(initializationSettings);
    await plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel!);
  }

  setup() {
    final plugin = FlutterLocalNotificationsPlugin();
    if (defaultTargetPlatform == TargetPlatform.android) {
      _setupAndroidChannel(plugin);
    }
  }

  showPushNotificaiton(RemoteMessage message) async {
    var notification = message.notification;
    if (_channel == null || notification == null) {
      return;
    }
    await FlutterLocalNotificationsPlugin().show(
      0,
      notification.title,
      notification.body,
      NotificationDetails(
        android: _getAndroidNotification(),
      ),
    );
  }

  AndroidNotificationDetails? _getAndroidNotification() {
    if (_channel == null) return null;
    return AndroidNotificationDetails(
      _channel!.id,
      _channel!.name,
      channelDescription: _channel!.description,
      importance: _channel!.importance,
      enableVibration: _channel!.enableVibration,
    );
  }
}
