import 'package:mangxahoi/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> login({required String email, required String password});

  Future<void> logout();

  Stream<bool> isLoggedInStream();

  Future<User?> getCurrentUser();

  Future<void> updateUserProfile({
    required String userId,
    required String displayName,
    required String? bio,
  });

  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  });

  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  });

  Future<User?> getUserById(String userId);

  Future<List<User>> searchUsers(String query);
}
