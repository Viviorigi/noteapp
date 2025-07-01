import 'package:flutter/material.dart';
import 'package:prjnote/commons/UserProvider.dart';
import 'package:prjnote/commons/auth_guard.dart';
import 'package:prjnote/model/note.dart';
import 'package:prjnote/screens/ChangePasswordScreen.dart';
import 'package:prjnote/screens/DetailProfileScreen.dart';
import 'package:prjnote/screens/LoginScreen.dart';
import 'package:prjnote/screens/NotesFormScreen.dart';
import 'package:prjnote/screens/NotesListScreen.dart';
import 'package:prjnote/screens/NotesDetailScreen.dart';
import 'package:prjnote/screens/RegisterScreen.dart';
import 'package:prjnote/screens/SplashScreen.dart';
import 'package:prjnote/screens/UpdateProfileScreen.dart';
import 'package:provider/provider.dart';
import 'commons/theme_provider.dart';
void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
    ],
    child: const MyApp(),
  ),
  );
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
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),

          '/notes': (_) => const AuthGuard(child: NotesListScreen()),
          '/detailProfile': (_) => const AuthGuard(child: DetailProfileScreen()),
          '/updateProfile': (_) => const AuthGuard(child: UpdateProfileScreen()),
          '/changePassword': (_) => const AuthGuard(child: ChangePasswordScreen()),
          '/noteDetail': (context) {
            final note = ModalRoute.of(context)!.settings.arguments as Note;
            return AuthGuard(child: NoteDetailScreen(note: note));
          },
          '/noteForm': (context) {
            final note = ModalRoute.of(context)!.settings.arguments as Note?;
            return AuthGuard(
              child: NoteFormScreen(
                note: note != null ? {
                  'id': note.id,
                  'title': note.title,
                  'content': note.content,
                  'color': note.color,
                }: null,
              ),
            );
          },
        }
    );
  }
}



