import 'dart:convert';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'auth_api.dart';

///JWT token çözümleme, refresh, payload okuma, permission kontrolü.

class TokenManager {
  final AuthService authService;
  final AuthApi authApi;

  TokenManager({required this.authService, required this.authApi});

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    while (output.length % 4 != 0) {
      output += '=';
    }
    return utf8.decode(base64Url.decode(output));
  }

  Map<String, dynamic>? parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Geçersiz JWT token formatı.');
    }

    final payload = _decodeBase64(parts[1]);
    return json.decode(payload);
  }

  Future<Map<String, dynamic>?> getTokenPayload() async {
    final tokens = await authService.getTokens();
    final accessToken = tokens['accessToken'];

    if (accessToken != null) {
      try {
        return parseJwt(accessToken);
      } catch (e) {
        debugPrint('Token çözme hatası: $e');
      }
    }
    return null;
  }

  Future<bool> hasPermission(String requiredRole) async {
    final payload = await getTokenPayload();
    if (payload != null && payload.containsKey('roles')) {
      final roles = List<String>.from(payload['roles']);
      return roles.contains(requiredRole);
    }
    return false;
  }

  Future<bool> refreshToken() async {
    final tokens = await authService.getTokens();
    final refreshToken = tokens['refreshToken'];

    if (refreshToken != null) {
      final newToken = await authApi.refreshToken(refreshToken);
      if (newToken != null) {
        await authService.saveToken(newToken.accessToken, newToken.refreshToken);
        return true;
      }
    }
    return false;
  }

  Future<bool> isTokenExpired() async {
    final payload = await getTokenPayload();
    if (payload != null && payload.containsKey('exp')) {
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
      return DateTime.now().isAfter(expiryTime);
    }
    return true;
  }

  Future<String?> getValidAccessToken() async {
    if (await isTokenExpired()) {
      final success = await refreshToken();
      if (!success) {
        return null;
      }
    }

    final tokens = await authService.getTokens();
    return tokens['accessToken'];
  }
} 