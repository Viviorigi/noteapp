import 'package:flutter/material.dart';
import 'package:prjnote/commons/UserProvider.dart';
import 'package:prjnote/commons/common.dart';
import 'package:provider/provider.dart';

class DetailProfileScreen extends StatelessWidget {
  const DetailProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Không có thông tin người dùng")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin tài khoản"),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              "👋 Xin chào, ${user.fullName}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 36),
            CircleAvatar(
              radius: 80,
              backgroundColor: const Color(0xFF80D8FF),
              backgroundImage: (user.avatar != null && user.avatar!.isNotEmpty)
                  ? NetworkImage('${Common.domain}${user.avatar!}')
                  : null,
              child: (user.avatar == null || user.avatar!.isEmpty)
                  ? Text(
                user.fullName.isNotEmpty
                    ? user.fullName[0].toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 60, color: Colors.white),
              )
                  : null,
            ),
            const SizedBox(height: 30),
            _buildInfoRow("Họ tên", user.fullName),
            _buildInfoRow("Email", user.email),
            _buildInfoRow("Số điện thoại", user.phoneNumber ?? "Chưa có"),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/updateProfile');
              },
              icon: const Icon(Icons.edit),
              label: const Text("Chỉnh sửa hồ sơ"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF80D8FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/changePassword');
              },
              icon: const Icon(Icons.lock_outline),
              label: const Text("Đổi mật khẩu"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
