import 'package:flutter/material.dart';
import 'package:prjnote/model/note.dart';
import 'package:prjnote/services/noteService.dart';
import 'package:provider/provider.dart';
import '../commons/theme_provider.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isGridView = false;
  bool isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    try {
      final noteService = NoteService();
      final fetchedNotes = await noteService.getAllNotes();
      setState(() {
        notes = fetchedNotes;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi load note: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _confirmDelete(BuildContext context, int noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: const Text('Bạn có chắc chắn muốn xoá ghi chú này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await NoteService().deleteNote(noteId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xoá ghi chú thành công')),
                );
                _fetchNotes();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xoá thất bại')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xoá'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredNotes = notes.where((note) {
      final query = _searchQuery.toLowerCase();
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text("📒 Notes Menu", style: TextStyle(fontSize: 20)),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text("Theme"),
              trailing: DropdownButton<ThemeMode>(
                value: Provider.of<ThemeProvider>(context).themeMode,
                onChanged: (ThemeMode? mode) {
                  if (mode != null) {
                    Provider.of<ThemeProvider>(context, listen: false)
                        .setTheme(mode);
                  }
                },
                items: const [
                  DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
                  DropdownMenuItem(value: ThemeMode.system, child: Text("System")),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _isSearching
            ? IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
            });
          },
        )
            : IconButton(
          icon: Icon(Icons.menu,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: _isSearching
            ? TextField(
          autofocus: true,
          enableIMEPersonalizedLearning: true,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Tìm ghi chú...',
            border: InputBorder.none,
          ),
          style:
          TextStyle(color: isDark ? Colors.white : Colors.black),
        )
            : Text(
          'Notes',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          !_isSearching
              ? IconButton(
            icon: Icon(Icons.search,
                color: isDark ? Colors.white : Colors.black),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          )
              : IconButton(
            icon: Icon(Icons.clear,
                color: isDark ? Colors.white : Colors.black),
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
            },
          ),
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view,
                color: isDark ? Colors.white : Colors.black),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredNotes.isEmpty
          ? const Center(child: Text('Không có ghi chú nào.'))
          : Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: isGridView
            ? GridView.builder(
          itemCount: filteredNotes.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3 / 4,
          ),
          itemBuilder: (_, index) => _buildNoteCard(
              filteredNotes[index], isDark, true),
        )
            : ListView.separated(
          itemCount: filteredNotes.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: 12),
          itemBuilder: (_, index) => _buildNoteCard(
              filteredNotes[index], isDark, false),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/noteForm');
          if (result == true) _fetchNotes();
        },
        backgroundColor: Colors.black87,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNoteCard(Note note, bool isDark, bool isGrid) {
    final noteColor = Color(note.color);

    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          note.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Text(
            note.content,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              height: 1.3,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/noteForm',
                  arguments: note,
                );
                if (result == true) _fetchNotes();
              },
              icon: Icon(Icons.edit,
                  size: 20, color: isDark ? Colors.white : Colors.black),
            ),
            IconButton(
              onPressed: () => _confirmDelete(context, note.id),
              icon: Icon(Icons.delete,
                  size: 20, color: isDark ? Colors.white : Colors.black),
            ),
          ],
        ),
      ],
    );

    return isGrid
        ? Material(
      color: noteColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            '/noteDetail',
            arguments: note,
          );
          if (result == true) _fetchNotes();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: cardContent,
        ),
      ),
    )
        : Container(
      decoration: BoxDecoration(
        color: noteColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            '/noteDetail',
            arguments: note,
          );
          if (result == true) _fetchNotes();
        },
        title: Text(
          note.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          note.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/noteForm',
                  arguments: note,
                );
                if (result == true) _fetchNotes();
              },
              icon: Icon(Icons.edit,
                  size: 20, color: isDark ? Colors.white : Colors.black),
            ),
            IconButton(
              onPressed: () => _confirmDelete(context, note.id),
              icon: Icon(Icons.delete,
                  size: 20, color: isDark ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
