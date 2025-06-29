import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prjnote/commons/common.dart';
import 'package:prjnote/model/note.dart';

class NoteService {
  final String baseUrl = "${Common.domain}/api/notes";

  Future<List<Note>> getAllNotes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => Note.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load notes');
    }
  }

  Future<Note?> getNoteById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Note.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<void> createNote(Map<String, dynamic> note) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Lỗi khi tạo ghi chú');
    }
  }

  Future<void> updateNote(int id, Map<String, dynamic> note) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note),
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi cập nhật ghi chú');
    }
  }

  Future<bool> deleteNote(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 204;
  }

  Future<List<Note>> searchNotes(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search?q=$query'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => Note.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search notes');
    }
  }
}