import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:mangxahoi/features/auth/domain/entities/user.dart';
import 'package:mangxahoi/features/auth/data/datasources/remote_user_datasource.dart';

class RemoteAuthDatasource {
  final auth.FirebaseAuth _firebaseAuth;
  final RemoteUserDatasource _userDatasource;

  RemoteAuthDatasource({
    auth.FirebaseAuth? firebaseAuth,
    RemoteUserDatasource? userDatasource,
  }) : _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance,
       _userDatasource = userDatasource ?? RemoteUserDatasource();

  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Failed to create user');
    }

    // Update display name
    await firebaseUser.updateDisplayName(displayName);

    // Create user document in Firestore
    final user = await _userDatasource.createUser(
      email: email,
      userId: firebaseUser.uid,
      displayName: displayName,
    );

    return user;
  }

  Future<User> login({required String email, required String password}) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Failed to login');
    }

    // Get user from Firestore
    final user = await _userDatasource.getUserById(firebaseUser.uid);
    if (user == null) {
      throw Exception('User not found');
    }

    return user;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final user = await _userDatasource.getUserById(firebaseUser.uid);

      // If user doesn't exist in Firestore, create it
      if (user == null) {
        return await _userDatasource.createUser(
          email: firebaseUser.email ?? '',
          userId: firebaseUser.uid,
          displayName: firebaseUser.displayName ?? 'User',
        );
      }

      return user;
    } catch (e) {
      // If error loading from Firestore, return basic user info
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'User',
        username: firebaseUser.email?.split('@').first ?? 'user',
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
