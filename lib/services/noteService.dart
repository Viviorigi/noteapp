import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prjnote/commons/common.dart';
import 'package:prjnote/model/note.dart';
import 'package:prjnote/services/AuthService.dart';
// để lấy JWT

class NoteService {
  final String baseUrl = "${Common.domain}/api/notes";

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Note>> getAllNotes() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => Note.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi khi tải danh sách ghi chú');
    }
  }

  Future<Note?> getNoteById(int id) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: headers);

    if (response.statusCode == 200) {
      return Note.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<void> togglePin(int noteId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${Common.domain}/api/notes/$noteId/toggle-pin');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể cập nhật trạng thái pin');
    }
  }


  Future<void> createNote(Map<String, dynamic> note) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(note),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Lỗi khi tạo ghi chú');
    }
  }

  Future<void> updateNote(int id, Map<String, dynamic> note) async {
    final headers = await _getAuthHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: jsonEncode(note),
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi cập nhật ghi chú');
    }
  }

  Future<bool> deleteNote(int id) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: headers);
    return response.statusCode == 204;
  }

  Future<List<Note>> searchNotes(String query) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse('$baseUrl/search?q=$query'), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => Note.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi khi tìm kiếm ghi chú');
    }
  }
}
