import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/hive_service.dart';

class UserState {
  final String name;
  final String? imagePath;
  final String preferredMode; // 'Standard' or 'Scientific'

  UserState({
    this.name = 'User',
    this.imagePath,
    this.preferredMode = 'Standard',
  });

  UserState copyWith({String? name, String? imagePath, String? preferredMode}) {
    return UserState(
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      preferredMode: preferredMode ?? this.preferredMode,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState()) {
    _loadUser();
  }

  void _loadUser() {
    final box = HiveService.userBox;
    final name = box.get('name', defaultValue: 'User');
    final imagePath = box.get('imagePath');
    final mode = box.get('preferredMode', defaultValue: 'Standard');

    state = UserState(name: name, imagePath: imagePath, preferredMode: mode);
  }

  Future<void> updateName(String name) async {
    state = state.copyWith(name: name);
    await HiveService.userBox.put('name', name);
  }

  Future<void> updateImage(String path) async {
    state = state.copyWith(imagePath: path);
    await HiveService.userBox.put('imagePath', path);
  }

  Future<void> updatePreferredMode(String mode) async {
    state = state.copyWith(preferredMode: mode);
    await HiveService.userBox.put('preferredMode', mode);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
