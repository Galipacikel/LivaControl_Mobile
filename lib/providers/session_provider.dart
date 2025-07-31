import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/token_manager.dart';
import '../services/auth_api.dart';
import '../models/auth/user_model.dart';
import '../models/auth/token_model.dart';
import '../services/user_session.dart';

///Kullanıcı oturumu, login/logout, token ve kullanıcı bilgisini yönetir.

class SessionProvider with ChangeNotifier {
  final AuthService authService;
  late final TokenManager tokenManager;

  TokenModel? _token;
  UserModel? _currentUser;

  SessionProvider({required this.authService, required AuthApi authApi}) {
    tokenManager = TokenManager(authService: authService, authApi: authApi);
  }

  TokenModel? get token => _token;
  UserModel? get currentUser => _currentUser;

  Future<void> initializeSession() async {
    final tokens = await authService.getTokens();

    if (tokens['accessToken'] != null) {
      _token = TokenModel(
        accessToken: tokens['accessToken']!,
        refreshToken: tokens['refreshToken']!,
      );

      final payload = await tokenManager.getTokenPayload();
      if (payload != null) {
        _currentUser = UserModel.fromPayload(payload);
        UserSession().loadUser(_currentUser!);
      }
    } else {
      _token = null;
      _currentUser = null;
      UserSession().clear();
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    debugPrint('Giriş işlemi başlatılıyor...');

    final tokens = await tokenManager.authApi.login(username, password);

    if (tokens != null) {
      await authService.saveToken(tokens.accessToken, tokens.refreshToken);

      final payload = await tokenManager.getTokenPayload();
      if (payload != null) {
        _currentUser = UserModel.fromPayload(payload);
        UserSession().loadUser(_currentUser!);
        notifyListeners();
        return true;
      } else {
        debugPrint('Payload alınamadı.');
      }
    }

    debugPrint('Giriş başarısız.');
    return false;
  }

  Future<void> logout() async {
    await authService.clearToken();
    UserSession().clear();
    _token = null;
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    return _token != null;
  }

  void mockLogin() {
    _currentUser = UserModel(
      id: 'mock-id-123',
      username: 'Mock User',
      role: 'admin',
    );
    notifyListeners();
  }
}
