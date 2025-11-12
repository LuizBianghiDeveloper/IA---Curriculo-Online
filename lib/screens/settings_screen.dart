import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  bool _isConnected = false;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
    _testConnection();
  }

  Future<void> _loadCurrentUrl() async {
    final url = await ApiService.getCurrentBackendUrl();
    setState(() {
      _currentUrl = url;
      _urlController.text = url;
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _isConnected = false;
    });

    final isConnected = await ApiService.testConnection();
    
    setState(() {
      _isConnected = isConnected;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isConnected 
              ? 'Conexão com backend estabelecida!' 
              : 'Não foi possível conectar ao backend'),
          backgroundColor: isConnected ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _saveUrl() async {
    final url = _urlController.text.trim();
    
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe uma URL válida'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Valida formato básico da URL
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL deve começar com http:// ou https://'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await ApiService.setBackendUrl(url);
    await _loadCurrentUrl();
    await _testConnection();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL salva com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _resetUrl() async {
    await ApiService.resetBackendUrl();
    await _loadCurrentUrl();
    await _testConnection();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL resetada para o padrão'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.settings,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'URL do Backend',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: 'URL do Backend',
                        hintText: 'http://localhost:8080/api',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.link),
                        suffixIcon: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Icon(
                                _isConnected ? Icons.check_circle : Icons.error,
                                color: _isConnected ? Colors.green : Colors.red,
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentUrl != null
                          ? 'URL atual: $_currentUrl'
                          : 'Carregando...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _testConnection,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Testar Conexão'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _saveUrl,
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _resetUrl,
                      icon: const Icon(Icons.restore),
                      label: const Text('Restaurar Padrão'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Como Configurar',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      'Emulador Android',
                      'Use: http://10.0.2.2:8080/api\n(O app detecta automaticamente)',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      'iOS Simulator',
                      'Use: http://localhost:8080/api\n(O app detecta automaticamente)',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      'Dispositivo Físico',
                      'Use o IP da sua máquina:\nhttp://192.168.1.XXX:8080/api\n\nDescubra o IP:\nmacOS: ifconfig | grep "inet "\nWindows: ipconfig',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

