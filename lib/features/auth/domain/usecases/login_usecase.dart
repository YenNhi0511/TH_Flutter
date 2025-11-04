import 'package:mangxahoi/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  Future<void> call({required String email, required String password}) async {
    return authRepository.login(email: email, password: password);
  }
}
