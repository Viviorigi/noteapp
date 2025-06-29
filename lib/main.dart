import 'package:flutter/material.dart';
import 'package:prjnote/model/note.dart';
import 'package:prjnote/screens/NotesFormScreen.dart';
import 'package:prjnote/screens/NotesListScreen.dart';
import 'package:prjnote/screens/NotesDetailScreen.dart';
import 'package:provider/provider.dart';
import 'commons/theme_provider.dart';
void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: const MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeProvider.themeMode,
      home: NotesListScreen(),
      debugShowCheckedModeBanner: false,
        routes: {
          '/noteDetail': (context) {
            final note = ModalRoute.of(context)!.settings.arguments as Note;
            return NoteDetailScreen(note: note);
          },
          '/noteForm': (context) {
            final note = ModalRoute.of(context)!.settings.arguments as Note?;
            return NoteFormScreen(
              note: note != null
                  ? {
                'id': note.id,
                'title': note.title,
                'content': note.content,
                'color': note.color,
              }
                  : null,
            );
          },
        }
    );
  }
}



