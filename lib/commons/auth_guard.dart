import 'package:flutter/material.dart';
import 'package:prjnote/commons/UserProvider.dart';
import 'package:prjnote/screens/LoginScreen.dart';
import 'package:provider/provider.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      // Nếu chưa đăng nhập, chuyển về màn hình đăng nhập
      Future.microtask(() {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Nếu đã đăng nhập, trả về màn hình được bảo vệ
    return child;
  }
}
