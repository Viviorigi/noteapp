import 'package:flutter/material.dart';
import 'package:prjnote/model/note.dart';
import 'package:prjnote/services/noteService.dart';


class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  void _deleteNote(BuildContext context) async {
    try {
      await NoteService().deleteNote(note.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xoá ghi chú')),
      );
      Navigator.pop(context, true); // Trả về true để màn trước biết xoá xong
    } catch (e) {
      print("Lỗi xoá: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xoá thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final noteColor = Color(note.color);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Note Detail',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: isDark ? Colors.white : Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/noteForm', arguments: note);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: isDark ? Colors.white : Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Xác nhận xoá'),
                  content: const Text('Bạn có chắc muốn xoá ghi chú này không?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context,true); // đóng dialog
                        _deleteNote(context);
                      },
                      child: const Text('Xoá', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: noteColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    note.content,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
