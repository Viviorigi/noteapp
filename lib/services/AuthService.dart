import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:prjnote/model/RegisterRequest.dart';
import 'package:prjnote/model/usermodel.dart';
import '../commons/common.dart'; // import Common class

class AuthService {
  static const _storage = FlutterSecureStorage();

  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('${Common.domain}/api/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final token = body['token'];
      print(token);
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
        return true;
      }
    }

    return false;
  }

  static Future<bool> register(RegisterRequest data) async {
    final url = Uri.parse('${Common.domain}/api/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("Đăng ký thất bại: ${response.statusCode} - ${response.body}");
      return false;
    }
  }


  static Future<UserModel?> fetchUserInfo() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('${Common.domain}/api/auth/info'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      print(response);
      return UserModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}
