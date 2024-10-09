import 'package:flutter/material.dart';
import 'package:room_connect/api.dart';
import 'package:room_connect/utils/debouncer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? username;
  String? error;
  final Debouncer _debouncer = Debouncer();

  final TextEditingController userController = TextEditingController();

  bool _usernameValid = false;

  @override
  Widget build(BuildContext context) {
    if (username != null) {
      return buildHome();
    }

    return buildRegister();
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
                        Api.registerUser(username: userController.text.toString()).then((value) {
                          setState(() {
                            username = value;
                          });
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

  Widget buildHome() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome $username"),
      ),
      body: const Center(
        child: Text("No Rooms"),
      ),
    );
  }
}
