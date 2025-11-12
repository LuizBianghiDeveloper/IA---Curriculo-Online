import 'package:flutter/material.dart';
import '../models/vaga.dart';
import '../services/vaga_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'home_screen.dart';
import 'vaga_detalhes_screen.dart';

class VagasScreen extends StatefulWidget {
  const VagasScreen({super.key});

  @override
  State<VagasScreen> createState() => _VagasScreenState();
}

class _VagasScreenState extends State<VagasScreen> {
  List<Vaga> _vagas = [];
  bool _isLoading = true;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _carregarVagas();
  }

  Future<void> _loadUsername() async {
    final username = await AuthService.getUsername();
    if (mounted) {
      setState(() {
        _username = username;
      });
    }
  }

  Future<void> _carregarVagas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vagas = await VagaService.listarVagas();
      if (mounted) {
        setState(() {
          _vagas = vagas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar vagas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _excluirVaga(Vaga vaga) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir a vaga "${vaga.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      try {
        await VagaService.excluirVaga(vaga.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vaga excluída com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          _carregarVagas();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir vaga: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _abrirFormularioVaga({Vaga? vaga}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VagaFormScreen(vaga: vaga),
      ),
    );

    if (resultado == true) {
      _carregarVagas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vagas'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
            tooltip: 'Análise de Currículo',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Configurações',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) async {
              if (value == 'logout') {
                await AuthService.logout();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  'Usuário: ${_username ?? "Carregando..."}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vagas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma vaga cadastrada',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque no botão + para cadastrar uma nova vaga',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregarVagas,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _vagas.length,
                    itemBuilder: (context, index) {
                      final vaga = _vagas[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VagaDetalhesScreen(vaga: vaga),
                              ),
                            ).then((_) => _carregarVagas());
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            vaga.titulo,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            vaga.empresa,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                          ),
                                          if (vaga.curriculosAnexados.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.description,
                                                  size: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${vaga.curriculosAnexados.length} currículo${vaga.curriculosAnexados.length > 1 ? 's' : ''} anexado${vaga.curriculosAnexados.length > 1 ? 's' : ''}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Colors.grey[600],
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _abrirFormularioVaga(vaga: vaga);
                                        } else if (value == 'delete') {
                                          _excluirVaga(vaga);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 20),
                                              SizedBox(width: 8),
                                              Text('Editar'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, size: 20, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Excluir', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (vaga.localizacao != null ||
                                    vaga.tipoContrato != null) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      if (vaga.localizacao != null)
                                        Chip(
                                          label: Text(vaga.localizacao!),
                                          avatar: const Icon(
                                            Icons.location_on,
                                            size: 16,
                                          ),
                                          visualDensity:
                                              VisualDensity.compact,
                                        ),
                                      if (vaga.tipoContrato != null)
                                        Chip(
                                          label: Text(vaga.tipoContrato!),
                                          avatar: const Icon(
                                            Icons.business_center,
                                            size: 16,
                                          ),
                                          visualDensity:
                                              VisualDensity.compact,
                                        ),
                                    ],
                                  ),
                                ],
                                if (vaga.descricao.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    vaga.descricao,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                if (vaga.requisitos.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: vaga.requisitos
                                        .take(3)
                                        .map((req) => Chip(
                                              label: Text(
                                                req,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ))
                                        .toList(),
                                  ),
                                  if (vaga.requisitos.length > 3)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '+${vaga.requisitos.length - 3} mais',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormularioVaga(),
        icon: const Icon(Icons.add),
        label: const Text('Nova Vaga'),
      ),
    );
  }
}

class VagaFormScreen extends StatefulWidget {
  final Vaga? vaga;

  const VagaFormScreen({super.key, this.vaga});

  @override
  State<VagaFormScreen> createState() => _VagaFormScreenState();
}

class _VagaFormScreenState extends State<VagaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _empresaController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _localizacaoController = TextEditingController();
  final _tipoContratoController = TextEditingController();
  final _requisitoController = TextEditingController();
  List<String> _requisitos = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.vaga != null) {
      _tituloController.text = widget.vaga!.titulo;
      _empresaController.text = widget.vaga!.empresa;
      _descricaoController.text = widget.vaga!.descricao;
      _localizacaoController.text = widget.vaga!.localizacao ?? '';
      _tipoContratoController.text = widget.vaga!.tipoContrato ?? '';
      _requisitos = List<String>.from(widget.vaga!.requisitos);
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _empresaController.dispose();
    _descricaoController.dispose();
    _localizacaoController.dispose();
    _tipoContratoController.dispose();
    _requisitoController.dispose();
    super.dispose();
  }

  void _adicionarRequisito() {
    final requisito = _requisitoController.text.trim();
    if (requisito.isNotEmpty && !_requisitos.contains(requisito)) {
      setState(() {
        _requisitos.add(requisito);
        _requisitoController.clear();
      });
    }
  }

  void _removerRequisito(String requisito) {
    setState(() {
      _requisitos.remove(requisito);
    });
  }

  Future<void> _salvarVaga() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.vaga == null) {
        // Criar nova vaga
        await VagaService.criarVaga(
          titulo: _tituloController.text.trim(),
          empresa: _empresaController.text.trim(),
          descricao: _descricaoController.text.trim(),
          requisitos: _requisitos,
          localizacao: _localizacaoController.text.trim().isEmpty
              ? null
              : _localizacaoController.text.trim(),
          tipoContrato: _tipoContratoController.text.trim().isEmpty
              ? null
              : _tipoContratoController.text.trim(),
        );
      } else {
        // Atualizar vaga existente
        final vagaAtualizada = widget.vaga!.copyWith(
          titulo: _tituloController.text.trim(),
          empresa: _empresaController.text.trim(),
          descricao: _descricaoController.text.trim(),
          requisitos: _requisitos,
          localizacao: _localizacaoController.text.trim().isEmpty
              ? null
              : _localizacaoController.text.trim(),
          tipoContrato: _tipoContratoController.text.trim().isEmpty
              ? null
              : _tipoContratoController.text.trim(),
        );
        await VagaService.atualizarVaga(vagaAtualizada);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.vaga == null
                ? 'Vaga cadastrada com sucesso!'
                : 'Vaga atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar vaga: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vaga == null ? 'Nova Vaga' : 'Editar Vaga'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título da Vaga *',
                  hintText: 'Ex: Desenvolvedor Flutter',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Título é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _empresaController,
                decoration: const InputDecoration(
                  labelText: 'Empresa *',
                  hintText: 'Nome da empresa',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Empresa é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição *',
                  hintText: 'Descreva a vaga...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Descrição é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _localizacaoController,
                decoration: const InputDecoration(
                  labelText: 'Localização',
                  hintText: 'Ex: São Paulo - SP, Remoto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tipoContratoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Contrato',
                  hintText: 'Ex: CLT, PJ, Estágio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business_center),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Requisitos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _requisitoController,
                      decoration: const InputDecoration(
                        labelText: 'Adicionar requisito',
                        hintText: 'Ex: Flutter, 3 anos de experiência',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _adicionarRequisito(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _adicionarRequisito,
                    icon: const Icon(Icons.add_circle),
                    color: Theme.of(context).colorScheme.primary,
                    iconSize: 32,
                  ),
                ],
              ),
              if (_requisitos.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _requisitos.map((req) {
                    return Chip(
                      label: Text(req),
                      onDeleted: () => _removerRequisito(req),
                      deleteIcon: const Icon(Icons.close, size: 18),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSaving ? null : _salvarVaga,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(widget.vaga == null ? 'Cadastrar Vaga' : 'Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

