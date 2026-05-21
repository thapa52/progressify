import 'user_entity.dart';

class AuthEntity {
  final int status;
  final String message;
  final String token;
  final String tokenType;
  final UserEntity user;

  const AuthEntity({
    required this.status,
    required this.message,
    required this.token,
    required this.tokenType,
    required this.user,
  });
}
