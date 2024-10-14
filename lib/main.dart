import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:room_connect/api.dart';
import 'package:room_connect/firebase_options.dart';
import 'package:room_connect/presentation/home_view.dart';
import 'package:room_connect/services/notificaiton/fireabase_fcm_service.dart';
import 'package:room_connect/services/session/user_session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FireabaseFcmService fcmService = FireabaseFcmService(
    onToken: (token) {
      final username = GetIt.instance.get<UserSessionService>().getUserSessionSync()?.username;
      if (username == null) {
        return;
      }
      Api.setFCMToken(
        username,
        newToken: token,
      );
    },
    onRemoteMessageReceived: (message) {
      print(message.data);
    },
  );
  final userSessionService = UserSessionService();
  GetIt.instance.registerSingleton(fcmService);
  GetIt.instance.registerSingleton(userSessionService);
  await userSessionService.loadSession();
  await fcmService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}
