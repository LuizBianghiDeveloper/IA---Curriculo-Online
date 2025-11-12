import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'auth_username';
  static const String _nomeKey = 'auth_nome';
  static const String _emailKey = 'auth_email';

  /// Realiza login
  static Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final baseUrl = await ApiService.getCurrentBackendUrl();
      final url = baseUrl.replaceAll('/api', '/api/auth/login');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final jsonData = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(jsonData);

      if (authResponse.isSuccess) {
        await _saveAuthData(authResponse);
      }

      return authResponse;
    } catch (e) {
      return AuthResponse(message: 'Erro ao realizar login: $e');
    }
  }

  /// Registra novo usuário
  static Future<AuthResponse> register({
    required String username,
    required String password,
    required String email,
    required String nome,
  }) async {
    try {
      final baseUrl = await ApiService.getCurrentBackendUrl();
      final url = baseUrl.replaceAll('/api', '/api/auth/register');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
          'nome': nome,
        }),
      );

      final jsonData = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(jsonData);

      if (authResponse.isSuccess) {
        await _saveAuthData(authResponse);
      }

      return authResponse;
    } catch (e) {
      return AuthResponse(message: 'Erro ao registrar: $e');
    }
  }

  /// Realiza logout
  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        final baseUrl = await ApiService.getCurrentBackendUrl();
        final url = baseUrl.replaceAll('/api', '/api/auth/logout');
        
        await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      // Ignora erros no logout
    } finally {
      await _clearAuthData();
    }
  }

  /// Valida o token atual
  static Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final baseUrl = await ApiService.getCurrentBackendUrl();
      final url = baseUrl.replaceAll('/api', '/api/auth/validate');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Obtém o token atual
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Obtém o username atual
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  /// Verifica se está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;
    return await validateToken();
  }

  /// Salva dados de autenticação
  static Future<void> _saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    if (authResponse.token != null) {
      await prefs.setString(_tokenKey, authResponse.token!);
    }
    if (authResponse.username != null) {
      await prefs.setString(_usernameKey, authResponse.username!);
    }
    if (authResponse.nome != null) {
      await prefs.setString(_nomeKey, authResponse.nome!);
    }
    if (authResponse.email != null) {
      await prefs.setString(_emailKey, authResponse.email!);
    }
  }

  /// Limpa dados de autenticação
  static Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_nomeKey);
    await prefs.remove(_emailKey);
  }
}

