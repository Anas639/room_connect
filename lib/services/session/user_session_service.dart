import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:room_connect/user_session.dart';

class UserSessionService {
  final String _userKey = "user";
  UserSession? _userSession;

  UserSession? getUserSessionSync() {
    return _userSession;
  }

  Future loadSession() async {
    _userSession = await getUserSession();
  }

  Future<UserSession?> getUserSession() async {
    final json = await const FlutterSecureStorage().read(key: _userKey);
    if (json == null) {
      return null;
    }
    final session = UserSession.fromJson(jsonDecode(json));
    return session;
  }

  Future createSession(String username) {
    final session = UserSession(username: username, createdAt: DateTime.now());
    _userSession = session;
    final json = jsonEncode(session.toJson());
    return const FlutterSecureStorage().write(key: _userKey, value: json);
  }

  Future destroySession() {
    _userSession = null;
    return const FlutterSecureStorage().delete(key: _userKey);
  }
}
