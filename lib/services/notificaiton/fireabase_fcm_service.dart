import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:room_connect/firebase_options.dart';
import 'package:room_connect/services/notificaiton/push_notification_handler.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class FireabaseFcmService {
  final _pushNotificationHandler = PushNotificationHandler();
  final Function(String token) onToken;
  final Function(RemoteMessage message) onRemoteMessageReceived;

  FireabaseFcmService({
    required this.onToken,
    required this.onRemoteMessageReceived,
  });
  Future initialize() async {
    await _pushNotificationHandler.setup();
    await _requestPermissions();
    await _setupFCMTokenListener();
    await _setupMessageListener();
  }

  Future _setupMessageListener() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((message) {
      _handleRemoteNotification(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationPressed(message);
    });
  }

  void _handleNotificationPressed(message) {}

  void _handleRemoteNotification(RemoteMessage message) {
    onRemoteMessageReceived(message);
    _pushNotificationHandler.showPushNotificaiton(message);
  }

  Future _setupFCMTokenListener() async {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      onToken(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      onToken(newToken);
    });
  }

  Future _requestPermissions() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }
}
