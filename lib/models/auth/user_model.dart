class UserModel {
  ///Kullanıcı bilgisi modeli.

  final String id;
  final String username;
  final String role; // admin veya staff

  UserModel({required this.id, required this.username, required this.role});

  factory UserModel.fromPayload(Map<String, dynamic> payload) {
    return UserModel(
      id: payload['sub']?.toString() ?? '',
      username: payload['username']?.toString() ?? '',
      role: (payload['roles'] is List && payload['roles'].isNotEmpty)
          ? payload['roles'][0].toString()
          : (payload['role']?.toString() ?? 'staff'),
    );
  }
}
