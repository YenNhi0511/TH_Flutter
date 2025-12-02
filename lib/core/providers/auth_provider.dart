import 'package:flutter/material.dart';
import 'package:mangxahoi/features/auth/data/datasources/remote_auth_datasource.dart';
import 'package:mangxahoi/features/auth/data/datasources/remote_user_datasource.dart';
import 'package:mangxahoi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mangxahoi/features/auth/domain/entities/user.dart' as domain;

class AuthProvider with ChangeNotifier {
  final AuthRepositoryImpl _authRepository;
  domain.User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthRepositoryImpl? authRepository})
    : _authRepository =
          authRepository ??
          AuthRepositoryImpl(
            remoteDatasource: RemoteAuthDatasource(),
            userDatasource: RemoteUserDatasource(),
          );

  domain.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      await _loadCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.login(email: email, password: password);
      await _loadCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  /// Check authentication state and reload user data
  Future<void> checkAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadCurrentUser();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload profile photo
  Future<void> uploadProfilePhoto(String userId, String imagePath) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userDatasource = RemoteUserDatasource();
      await userDatasource.uploadProfilePhoto(userId, imagePath);
      // Reload user data after upload
      await _loadCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
