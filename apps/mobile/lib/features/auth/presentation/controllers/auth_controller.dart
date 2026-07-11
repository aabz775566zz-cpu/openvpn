import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/login_with_provider_usecase.dart';

/// Presentation-layer controller driving the login screen's state.
class AuthController extends ChangeNotifier {
  AuthController({required LoginWithProviderUseCase loginUseCase})
      : _loginUseCase = loginUseCase;

  final LoginWithProviderUseCase _loginUseCase;

  bool _isLoading = false;
  AuthUser? _user;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  AuthUser? get user => _user;
  String? get errorMessage => _errorMessage;

  Future<AuthUser?> loginWithProvider(AuthProviderType provider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _loginUseCase(provider);
      _user = user;
      return user;
    } catch (error) {
      _errorMessage = error.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
