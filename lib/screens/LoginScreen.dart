import 'package:flutter/material.dart';
import 'package:prjnote/commons/UserProvider.dart';
import 'package:prjnote/services/AuthService.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      final success = await AuthService.login(email, password);
      if (success) {
        final user = await AuthService.fetchUserInfo();
        if (user != null && context.mounted) {
          Provider.of<UserProvider>(context, listen: false).setUser(user);
        }
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/notes');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập thất bại')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accentColor = Color(0xFF80D8FF); // Màu xanh nhạt

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Icon(Icons.note_alt_outlined, size: 100, color: accentColor),
                const SizedBox(height: 10),
                Text(
                  "Welcome to NoteApp",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 30),

                // Email
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: accentColor),
                    prefixIcon: Icon(Icons.email, color: accentColor),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accentColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                    if (!value.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Mật khẩu
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    labelStyle: TextStyle(color: accentColor),
                    prefixIcon: Icon(Icons.lock, color: accentColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accentColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                    if (value.length < 6) return 'Ít nhất 6 ký tự';
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Nút đăng nhập
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Quên mật khẩu
                TextButton(
                  onPressed: () {
                    // TODO: Điều hướng tới màn hình quên mật khẩu
                  },
                  child: Text(
                    'Quên mật khẩu?',
                    style: TextStyle(color: theme.textTheme.bodySmall?.color),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Chưa có tài khoản?",
                      style: TextStyle(color: theme.textTheme.bodySmall?.color),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register'); // hoặc push tới màn đăng ký
                      },
                      child: const Text(
                        "Tạo tài khoản",
                        style: TextStyle(
                          color: Color(0xFF80D8FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
