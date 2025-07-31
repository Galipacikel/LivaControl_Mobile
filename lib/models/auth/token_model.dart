class TokenModel {

///Giriş/kimlik doğrulama için token modeli.

  final String accessToken;
  final String refreshToken;

  TokenModel({required this.accessToken, required this.refreshToken});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['accessToken'] ?? json['AccessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? json['RefreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };
} 