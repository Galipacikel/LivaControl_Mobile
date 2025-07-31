class UserSession {

///Kullanıcı oturumu yönetimi (singleton).

  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  // Example user data
  dynamic _user;

  void loadUser(dynamic user) {
    _user = user;
  }

  dynamic get user => _user;

  void clear() {
    _user = null;
  }
} 