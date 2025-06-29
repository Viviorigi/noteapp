import 'package:flutter/material.dart';
import '../services/noteService.dart'; // Sửa đúng path nếu khác

class NoteFormScreen extends StatefulWidget {
  final Map<String, dynamic>? note;

  const NoteFormScreen({Key? key, this.note}) : super(key: key);

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int selectedColor = 0xFF80D8FF;
  bool isSaving = false;

  final List<int> colorOptions = [
    0xFFFF8A80, // red
    0xFFFFB6F9, // pink
    0xFFB9F6CA, // green
    0xFF80D8FF, // blue
    0xFFFFF59D, // yellow
    0xFFD7CCC8, // brownish
    0xFFCFD8DC, // grey blue
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!['title'] ?? '';
      _contentController.text = widget.note!['content'] ?? '';
      selectedColor = widget.note!['color'] ?? 0xFF80D8FF;
    }
  }

  Future<void> _saveNote() async {
    setState(() => isSaving = true);

    final newNote = {
      'title': _titleController.text,
      'content': _contentController.text,
      'color': selectedColor,
    };

    try {
      final noteService = NoteService();

      if (widget.note != null) {
        final id = widget.note!['id'];
        await noteService.updateNote(id, newNote);
      } else {
        await noteService.createNote(newNote);
      }

      Navigator.pop(context, true); // Đánh dấu đã lưu thành công
    } catch (e) {
      print("Lỗi lưu ghi chú: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi lưu ghi chú!')),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.note != null ? 'Edit Note' : 'Add Note'),
        actions: [
          isSaving
              ? const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: CircularProgressIndicator()),
          )
              : IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                decoration: const InputDecoration(
                  hintText: 'Type something...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: colorOptions.map((color) {
                final isSelected = color == selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(color),
                      border: isSelected ? Border.all(width: 3, color: Colors.black) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
