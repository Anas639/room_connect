import 'dart:convert';

import 'package:http/http.dart';

class Api {
  static String baseURL = "http://192.168.1.110:3000";

  static Future<String> registerUser({required String username}) async {
    String uri = "$baseURL/users/register";
    final response = await post(Uri.parse(uri),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "username": username,
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
}
