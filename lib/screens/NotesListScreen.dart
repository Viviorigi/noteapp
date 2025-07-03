import 'package:flutter/material.dart';
import 'package:prjnote/commons/SortOption.dart';
import 'package:prjnote/commons/UserProvider.dart';
import 'package:prjnote/commons/common.dart';
import 'package:prjnote/model/note.dart';
import 'package:prjnote/services/AuthService.dart';
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
  late TextEditingController _searchController;
  SortOption _sortOption = SortOption.dateNewest;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotes() async {
    try {
      final noteService = NoteService();
      final fetchedNotes = await noteService.getAllNotes();
      setState(() {
        notes = fetchedNotes;
        _applySorting();
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi load note: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _applySorting() {
    final pinnedNotes = notes.where((note) => note.pinned).toList();
    final unpinnedNotes = notes.where((note) => !note.pinned).toList();

    int compare(Note a, Note b) {
      switch (_sortOption) {
        case SortOption.titleAsc:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SortOption.titleDesc:
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
        case SortOption.dateNewest:
          return b.createdAt.compareTo(a.createdAt); // newest first
        case SortOption.dateOldest:
          return a.createdAt.compareTo(b.createdAt);
      }
    }
    pinnedNotes.sort(compare);
    unpinnedNotes.sort(compare);

    setState(() {
      notes = [...pinnedNotes, ...unpinnedNotes];
    });
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
                _fetchNotes();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xoá ghi chú thành công')),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Xoá thất bại')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xoá'),
          ),
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
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.user;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/detailProfile');
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                    color: Theme.of(context).colorScheme.surface,
                    child: Row(
                      children: [
                        user?.avatar != null && user!.avatar!.isNotEmpty
                            ? CircleAvatar(
                                radius: 40, // to hơn rõ rệt
                                backgroundImage: NetworkImage(
                                  '${Common.domain}${user.avatar!}',
                                ),
                              )
                            : CircleAvatar(
                                radius: 40,
                                backgroundColor: const Color(0xFF80D8FF),
                                child: Text(
                                  (user?.fullName.isNotEmpty == true
                                      ? user!.fullName[0].toUpperCase()
                                      : '?'),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.fullName ?? 'Chưa có tên',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'Chưa có email',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Cập nhật thông tin"),
                  onTap: () {
                    Navigator.pushNamed(context, '/updateProfile');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text("Đổi mật khẩu"),
                  onTap: () {
                    Navigator.pushNamed(context, '/changePassword');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text("Theme"),
                  trailing: DropdownButton<ThemeMode>(
                    value: Provider.of<ThemeProvider>(context).themeMode,
                    onChanged: (ThemeMode? mode) {
                      if (mode != null) {
                        Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        ).setTheme(mode);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text("Light"),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text("Dark"),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text("System"),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Đăng xuất"),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xác nhận'),
                        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context), // Huỷ
                            child: const Text('Huỷ'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context); // đóng dialog
                              await AuthService.logout();
                              if (context.mounted) {
                                Provider.of<UserProvider>(
                                  context,
                                  listen: false,
                                ).clearUser();
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/login',
                                  (route) => false,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Đăng xuất'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _isSearching
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                  });
                },
              )
            : IconButton(
                icon: Icon(
                  Icons.menu,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Tìm ghi chú...',
                  border: InputBorder.none,
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
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
          PopupMenuButton<SortOption>(
            icon: Icon(Icons.sort, color: isDark ? Colors.white : Colors.black),
            onSelected: (SortOption selected) {
              setState(() {
                _sortOption = selected;
                _applySorting();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.titleAsc,
                child: Text('Tiêu đề A-Z'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.titleDesc,
                child: Text('Tiêu đề Z-A'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.dateNewest,
                child: Text('Mới nhất'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.dateOldest,
                child: Text('Cũ nhất'),
              ),
            ],
          ),

          !_isSearching
              ? IconButton(
                  icon: Icon(
                    Icons.search,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
          IconButton(
            icon: Icon(
              isGridView ? Icons.view_list : Icons.grid_view,
              color: isDark ? Colors.white : Colors.black,
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      itemBuilder: (_, index) =>
                          _buildNoteCard(filteredNotes[index], isDark, true),
                    )
                  : ListView.separated(
                      itemCount: filteredNotes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) =>
                          _buildNoteCard(filteredNotes[index], isDark, false),
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

    final cardContent = Stack(
      children: [
        // Nội dung note (title + content + actions)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24), // tạo khoảng cách phía dưới nút pin
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
                  icon: Icon(
                    Icons.edit,
                    size: 20,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => _confirmDelete(context, note.id),
                  icon: Icon(
                    Icons.delete,
                    size: 20,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Nút pin ở góc phải trên
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Icon(
              note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () async {
              await NoteService().togglePin(note.id);
              _fetchNotes();
            },
          ),
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
        :InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          '/noteDetail',
          arguments: note,
        );
        if (result == true) _fetchNotes();
      },
      child: Container(
        decoration: BoxDecoration(
          color: noteColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              // Nội dung ghi chú
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5), // Chừa chỗ cho nút pin
                  Text(
                    note.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    note.content,
                    maxLines: isGrid ? 5 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
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
                        icon: Icon(
                          Icons.edit,
                          size: 22,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _confirmDelete(context, note.id),
                        icon: Icon(
                          Icons.delete,
                          size: 22,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Nút pin ở góc trên bên phải
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(
                    note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 20,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    await NoteService().togglePin(note.id);
                    _fetchNotes();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



