import 'package:flutter/material.dart';
import 'package:prjnote/model/changePasswordRequest.dart';
import 'package:prjnote/services/AuthService.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  void _submitChangePassword() async {
    if (_formKey.currentState!.validate()) {
      final request = ChangePasswordRequest(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      final success = await AuthService.changePassword(request);
      if (!mounted) return;

      if (success) {
        // Xoá token, logout
        await AuthService.logout();

        // Hiển thị thông báo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi mật khẩu thành công. Vui lòng đăng nhập lại.')),
        );

        // Chuyển về trang đăng nhập, xoá toàn bộ route stack
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi mật khẩu thất bại')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đổi mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu cũ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập mật khẩu cũ'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu mới',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.length < 6
                    ? 'Mật khẩu mới ít nhất 6 ký tự'
                    : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _submitChangePassword,
                icon: const Icon(Icons.lock),
                label: const Text("Đổi mật khẩu"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
