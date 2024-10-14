import 'dart:convert';

import 'package:http/http.dart';

class Api {
  static String baseURL = "http://192.168.1.110:3000";

  static Future<String> registerUser({
    required String username,
    String? fcmToken,
  }) async {
    String uri = "$baseURL/users/register";
    final response = await post(Uri.parse(uri),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "username": username,
          if (fcmToken != null) "fcm_token": fcmToken,
        }));
    if (response.statusCode == 200) {
      return username;
    }
    String msg = "Server Error";
    try {
      final body = response.body;
      final json = jsonDecode(body);
      msg = json['msg']!;
    } catch (e) {
      msg = e.toString();
    }
    return Future.error(msg);
  }

  static Future<bool> checkUserExists(String value) async {
    if (value.isEmpty) {
      return false;
    }
    String uri = "$baseURL/exists/$value";
    final response = await get(
      Uri.parse(uri),
      headers: {
        "Content-Type": "application/json",
      },
    );
    var exists = false;
    if (response.statusCode != 200) {
      return false;
    }

    try {
      final body = response.body;
      final json = jsonDecode(body);
      exists = json['success'] ?? false;
    } catch (_) {}
    return exists;
  }

  static Future setFCMToken(String username, {required String newToken}) async {
    String uri = "$baseURL/users/$username/fcmtoken";
    final response = await put(Uri.parse(uri),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "fcm_token": newToken,
        }));
    if (response.statusCode == 200) {
      return username;
    }
  }

  static Future logout(String username) async {
    String uri = "$baseURL/users/$username";
    await delete(
      Uri.parse(uri),
      headers: {
        "Content-Type": "application/json",
      },
    );
  }
}
