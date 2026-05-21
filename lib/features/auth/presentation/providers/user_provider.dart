import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/models/user_model.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserEntity?>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return UserNotifier(localStorage: localStorage);
});

class UserNotifier extends StateNotifier<UserEntity?> {
  final LocalStorage _localStorage;

  UserNotifier({required LocalStorage localStorage})
    : _localStorage = localStorage,
      super(null) {
    _loadUser();
  }

  void _loadUser() {
    final userJson = _localStorage.getUser();
    if (userJson != null) {
      state = UserModel.fromJson(userJson);
    }
  }

  void updateUser(UserEntity user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }
}
