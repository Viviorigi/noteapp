import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:prjnote/model/changePasswordRequest.dart';
import 'package:prjnote/model/registerRequest.dart';
import 'package:prjnote/model/userModel.dart';
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

  static Future<UserModel?> updateProfile({
    required String fullName,
    required String phoneNumber,
    File? avatarFile,
  }) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;

    var uri = Uri.parse('${Common.domain}/api/auth/update');
    var request = http.MultipartRequest('PUT', uri);

    // Thêm headers
    request.headers['Authorization'] = 'Bearer $token';

    // Thêm fields
    request.fields['fullName'] = fullName;
    request.fields['phoneNumber'] = phoneNumber;

    // Thêm file nếu có
    if (avatarFile != null) {
      final avatar = await http.MultipartFile.fromPath(
        'avatar',
        avatarFile.path,
      );
      request.files.add(avatar);
    }

    // Gửi request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserModel.fromJson(json);
    } else {
      print("Update thất bại: ${response.body}");
      return null;
    }
  }

  static Future<bool> changePassword(ChangePasswordRequest request) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('${Common.domain}/api/auth/change-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    return response.statusCode == 200;
  }
}
