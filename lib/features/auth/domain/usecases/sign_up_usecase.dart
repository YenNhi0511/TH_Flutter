import 'package:mangxahoi/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository authRepository;

  SignUpUseCase(this.authRepository);

  Future<void> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return authRepository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
