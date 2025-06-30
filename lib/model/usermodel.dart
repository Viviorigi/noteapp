class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? avatar;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      avatar: json['avatar'],
    );
  }
}
