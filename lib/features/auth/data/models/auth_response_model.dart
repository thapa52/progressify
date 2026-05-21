import '../../domain/entities/auth_entity.dart';
import 'user_model.dart';

class AuthResponseModel extends AuthEntity {
  const AuthResponseModel({
    required super.status,
    required super.message,
    required super.token,
    required super.tokenType,
    required UserModel super.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      token: json['token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'Bearer',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'token': token,
      'token_type': tokenType,
      'user': (user as UserModel).toJson(),
    };
  }
}
