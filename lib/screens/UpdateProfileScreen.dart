import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prjnote/commons/UserProvider.dart';
import 'package:prjnote/commons/common.dart';
import 'package:prjnote/services/AuthService.dart';
import 'package:provider/provider.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;

  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user!;
    _fullNameController = TextEditingController(text: user.fullName);
    _phoneController = TextEditingController(text: user.phoneNumber ?? '');
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  void _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      final fullName = _fullNameController.text;
      final phone = _phoneController.text;

      // Gọi API update profile
      final updatedUser = await AuthService.updateProfile(
        fullName: fullName,
        phoneNumber: phone,
        avatarFile: _avatarFile,
      );

      if (updatedUser != null && mounted) {
        // Cập nhật Provider
        Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thất bại. Vui lòng thử lại!')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;
    final avatarUrl =
    user.avatar != null ? '${Common.domain}${user.avatar}' : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa hồ sơ"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 90,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : (avatarUrl != null ? NetworkImage(avatarUrl) : null)
                      as ImageProvider?,
                      backgroundColor: const Color(0xFF80D8FF),
                      child: _avatarFile == null && avatarUrl == null
                          ? Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontSize: 40, color: Colors.white),
                      )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.image, size: 20, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Họ tên',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Nhập họ tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _submitUpdate,
                icon: const Icon(Icons.save),
                label: const Text("Lưu thay đổi"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF80D8FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
