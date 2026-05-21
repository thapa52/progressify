import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final Map<String, dynamic> rawJson;

  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.avatar,
    required this.rawJson,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() {
    return rawJson;
  }
}
