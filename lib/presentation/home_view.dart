import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:room_connect/api.dart';
import 'package:room_connect/services/notificaiton/fireabase_fcm_service.dart';
import 'package:room_connect/services/session/user_session_service.dart';
import 'package:room_connect/utils/debouncer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? error;
  final Debouncer _debouncer = Debouncer();

  final TextEditingController userController = TextEditingController();

  bool _usernameValid = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.instance.get<UserSessionService>().getUserSession(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user != null) {
          return buildHome(username: user.username);
        }

        return buildRegister();
      },
    );
  }

  Widget buildRegister() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Register username"),
              const SizedBox(
                height: 12,
              ),
              TextField(
                onChanged: (value) {
                  _debouncer.debounce(
                    () {
                      Api.checkUserExists(value).then((value) {
                        setState(() {
                          _usernameValid = !value;
                          error = _usernameValid ? null : "User already exists, please use another name";
                        });
                      }).catchError((error) {
                        setState(() {
                          this.error = error;
                        });
                      });
                    },
                    duration: const Duration(
                      seconds: 1,
                    ),
                  );
                },
                controller: userController,
                decoration: InputDecoration(
                  hintText: "Ex: codinarium",
                  suffixIcon: _usernameValid
                      ? const Icon(
                          Icons.check,
                          color: Colors.lightGreen,
                        )
                      : const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton(
                onPressed: _usernameValid
                    ? () {
                        Api.registerUser(
                          username: userController.text.toString(),
                          fcmToken: GetIt.instance.get<FireabaseFcmService>().fcmToken,
                        ).then((value) async {
                          await GetIt.instance.get<UserSessionService>().createSession(value);
                          setState(() {});
                        }).catchError((error) {
                          setState(() {
                            this.error = error;
                          });
                        });
                      }
                    : null,
                child: const Text("Register"),
              ),
              const SizedBox(
                height: 24,
              ),
              if (error != null)
                Text(
                  error!,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHome({required String username}) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome $username"),
        actions: [
          IconButton(
            onPressed: () async {
              final session = GetIt.instance.get<UserSessionService>();
              final user = session.getUserSessionSync();
              if (user == null) {
                return;
              }
              await session.destroySession();
              await Api.logout(user.username);
              setState(() {});
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text("No Rooms"),
      ),
    );
  }
}
