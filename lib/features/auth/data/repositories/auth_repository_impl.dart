import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:mangxahoi/features/auth/domain/entities/user.dart';
import 'package:mangxahoi/features/auth/domain/repositories/auth_repository.dart';
import 'package:mangxahoi/features/auth/data/datasources/remote_auth_datasource.dart';
import 'package:mangxahoi/features/auth/data/datasources/remote_user_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteAuthDatasource _remoteDatasource;
  final RemoteUserDatasource _userDatasource;

  AuthRepositoryImpl({
    RemoteAuthDatasource? remoteDatasource,
    RemoteUserDatasource? userDatasource,
  }) : _remoteDatasource = remoteDatasource ?? RemoteAuthDatasource(),
       _userDatasource = userDatasource ?? RemoteUserDatasource();

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      await _remoteDatasource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
    } on auth.FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseException(e));
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      await _remoteDatasource.login(email: email, password: password);
    } on auth.FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseException(e));
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDatasource.logout();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Stream<bool> isLoggedInStream() {
    return _remoteDatasource.authStateChanges.map((user) => user != null);
  }

  @override
  Future<User?> getCurrentUser() async {
    return _remoteDatasource.getCurrentUser();
  }

  @override
  Future<void> updateUserProfile({
    required String userId,
    required String displayName,
    required String? bio,
  }) async {
    await _userDatasource.updateUserProfile(
      userId: userId,
      displayName: displayName,
      bio: bio,
    );
  }

  @override
  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    await _userDatasource.followUser(
      currentUserId: currentUserId,
      targetUserId: targetUserId,
    );
  }

  @override
  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    await _userDatasource.unfollowUser(
      currentUserId: currentUserId,
      targetUserId: targetUserId,
    );
  }

  @override
  Future<User?> getUserById(String userId) async {
    return _userDatasource.getUserById(userId);
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    return _userDatasource.searchUsers(query);
  }

  String _mapFirebaseException(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      case 'email-already-in-use':
        return 'Email đã tồn tại';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'user-not-found':
        return 'Người dùng không tồn tại';
      case 'wrong-password':
        return 'Mật khẩu sai';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu, vui lòng thử lại sau';
      default:
        return e.message ?? 'Có lỗi xảy ra';
    }
  }
}
