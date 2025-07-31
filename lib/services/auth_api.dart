import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/auth/token_model.dart';

/// Giriş kimlik dogrulama için API cagrıları

class AuthApi {
  final String baseUrl;

  AuthApi({required this.baseUrl});

  Future<TokenModel?> login(String username, String password) async {
    debugPrint('Navigating to post');
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/Security/Login'), // Removed leading space
            headers: {'Content-Type': 'application/json'},
            body: json.encode(
                {'Username': username, 'Password': password, 'IsDomain': false}),
          )
          .timeout(const Duration(seconds: 2));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return TokenModel.fromJson(json.decode(response.body));
      }
      return null;
    } on TimeoutException {
      debugPrint('Login request timed out.');
      return null;
    } catch (e) {
      debugPrint('Login request failed with error: $e');
      return null;
    }
  }

  Future<TokenModel?> refreshToken(String refreshToken) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/Security/RefreshToken'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        return TokenModel.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('RefreshToken request failed with error: $e');
      return null;
    }
  }
} 