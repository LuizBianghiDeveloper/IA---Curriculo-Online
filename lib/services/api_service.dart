import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/curriculo_analysis.dart';
import '../models/vaga_description.dart';

class ApiService {
  // URL padrão - será detectada automaticamente ou pode ser configurada
  static const String _defaultBaseUrl = 'http://localhost:8080/api';
  
  // Para emulador Android: use 10.0.2.2 ao invés de localhost
  // Para iOS Simulator: use localhost normalmente
  // Para dispositivo físico: use o IP da sua máquina (ex: http://192.168.1.100:8080/api)
  
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final customUrl = prefs.getString('backend_url');
    
    if (customUrl != null && customUrl.isNotEmpty) {
      return customUrl;
    }
    
    // Detecta automaticamente se está em emulador Android
    if (Platform.isAndroid) {
      // Em emulador Android, localhost aponta para o próprio dispositivo
      // Use 10.0.2.2 para acessar o localhost da máquina host
      return 'http://10.0.2.2:8080/api';
    }
    
    // iOS Simulator e outros: usa localhost
    return _defaultBaseUrl;
  }
  
  /// Configura a URL do backend manualmente
  static Future<void> setBackendUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backend_url', url);
  }
  
  /// Remove a configuração customizada (volta ao padrão)
  static Future<void> resetBackendUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('backend_url');
  }

  /// Envia o currículo e descrição da vaga para análise
  static Future<CurriculoAnalysis> analyzeCurriculo({
    required File curriculoFile,
    required VagaDescription vagaDescription,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/analyze'),
      );

      // Adiciona o arquivo do currículo
      request.files.add(
        await http.MultipartFile.fromPath(
          'curriculo',
          curriculoFile.path,
        ),
      );

      // Adiciona os dados da vaga como JSON
      request.fields['vaga'] = jsonEncode(vagaDescription.toJson());

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CurriculoAnalysis.fromJson(jsonData);
      } else {
        final errorBody = response.body.isNotEmpty 
            ? jsonDecode(response.body) 
            : null;
        final errorMessage = errorBody != null && errorBody['summary'] != null
            ? errorBody['summary']
            : 'Erro ao analisar currículo: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      throw Exception('Erro de conexão: Verifique se o backend está rodando em ${await getBaseUrl()}');
    } catch (e) {
      throw Exception('Erro na comunicação com o servidor: $e');
    }
  }

  /// Testa a conexão com o backend
  static Future<bool> testConnection() async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Obtém a URL atual configurada
  static Future<String> getCurrentBackendUrl() async {
    return await getBaseUrl();
  }
}

