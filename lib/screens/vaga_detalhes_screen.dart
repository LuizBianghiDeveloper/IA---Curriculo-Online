import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/vaga.dart';
import '../models/curriculo_anexado.dart';
import '../services/vaga_service.dart';
import '../services/api_service.dart';
import 'analysis_result_screen.dart';
import 'ranking_screen.dart';

class VagaDetalhesScreen extends StatefulWidget {
  final Vaga vaga;

  const VagaDetalhesScreen({
    super.key,
    required this.vaga,
  });

  @override
  State<VagaDetalhesScreen> createState() => _VagaDetalhesScreenState();
}

class _VagaDetalhesScreenState extends State<VagaDetalhesScreen> {
  late Vaga _vaga;
  bool _isLoading = false;
  bool _isAnalyzing = false;
  String? _curriculoEmAnalise;

  @override
  void initState() {
    super.initState();
    _vaga = widget.vaga;
    _carregarVaga();
  }

  Future<void> _carregarVaga() async {
    final vagaAtualizada = await VagaService.buscarVagaPorId(_vaga.id);
    if (vagaAtualizada != null && mounted) {
      setState(() {
        _vaga = vagaAtualizada;
      });
    }
  }

  Future<String?> _solicitarNomeCandidato(String nomeArquivo) async {
    final nomeController = TextEditingController();
    
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nome do Candidato'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Informe o nome do candidato para:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              nomeArquivo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Candidato *',
                hintText: 'Ex: João Silva',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final nome = nomeController.text.trim();
              if (nome.isNotEmpty) {
                Navigator.pop(context, nome);
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _anexarCurriculos() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _isLoading = true;
        });

        int sucesso = 0;
        int erros = 0;

        for (var file in result.files) {
          if (file.path != null) {
            // Solicita o nome do candidato
            final nomeCandidato = await _solicitarNomeCandidato(file.name);
            
            // Se o usuário cancelou, pula este arquivo
            if (nomeCandidato == null || nomeCandidato.isEmpty) {
              continue;
            }

            try {
              // Anexa o currículo
              final vagaAtualizada = await VagaService.anexarCurriculo(
                vagaId: _vaga.id,
                caminhoArquivo: file.path!,
                nomeArquivo: file.name,
                nomeCandidato: nomeCandidato,
              );

              // Atualiza a vaga local para ter o currículo recém-anexado
              setState(() {
                _vaga = vagaAtualizada;
              });

              // Busca o currículo recém-anexado
              final curriculoAnexado = vagaAtualizada.curriculosAnexados.last;
              final arquivo = File(file.path!);

              // Analisa automaticamente
              try {
                if (mounted) {
                  setState(() {
                    _isAnalyzing = true;
                    _curriculoEmAnalise = curriculoAnexado.id;
                  });
                }

                final analysis = await ApiService.analyzeCurriculo(
                  curriculoFile: arquivo,
                  vagaDescription: _vaga.toVagaDescription(),
                );

                // Salva a análise no currículo
                await VagaService.atualizarAnaliseCurriculo(
                  vagaId: _vaga.id,
                  curriculoId: curriculoAnexado.id,
                  analise: analysis,
                );

                sucesso++;
              } catch (e) {
                // Erro na análise, mas o currículo foi anexado
                erros++;
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Currículo "${file.name}" anexado, mas erro na análise: $e'),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isAnalyzing = false;
                    _curriculoEmAnalise = null;
                  });
                }
              }
            } catch (e) {
              erros++;
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao anexar ${file.name}: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        }

        if (mounted) {
          _carregarVaga();
          
          String mensagem;
          if (sucesso > 0 && erros == 0) {
            mensagem = sucesso == 1
                ? 'Currículo anexado e analisado com sucesso!'
                : '$sucesso currículos anexados e analisados com sucesso!';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(mensagem),
                backgroundColor: Colors.green,
              ),
            );
          } else if (sucesso > 0 && erros > 0) {
            mensagem = '$sucesso anexado(s) com sucesso, $erros erro(s)';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(mensagem),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar arquivos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removerCurriculo(CurriculoAnexado curriculo) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Remoção'),
        content: Text(
          curriculo.nomeCandidato.isNotEmpty
              ? 'Deseja realmente remover o currículo de "${curriculo.nomeCandidato}"?'
              : 'Deseja realmente remover o currículo "${curriculo.nomeArquivo}"?',
        ),
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
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      try {
        await VagaService.removerCurriculo(
          vagaId: _vaga.id,
          curriculoId: curriculo.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Currículo removido com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          _carregarVaga();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao remover currículo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _analisarCurriculo(CurriculoAnexado curriculo) async {
    final arquivo = curriculo.obterArquivo();
    if (arquivo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arquivo não encontrado. Por favor, anexe novamente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _curriculoEmAnalise = curriculo.id;
    });

    try {
      final analysis = await ApiService.analyzeCurriculo(
        curriculoFile: arquivo,
        vagaDescription: _vaga.toVagaDescription(),
      );

      // Salva a análise no currículo
      await VagaService.atualizarAnaliseCurriculo(
        vagaId: _vaga.id,
        curriculoId: curriculo.id,
        analise: analysis,
      );

      if (mounted) {
        _carregarVaga();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(
              analysis: analysis,
              vagaDescription: _vaga.toVagaDescription(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao analisar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _curriculoEmAnalise = null;
        });
      }
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_vaga.titulo),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card com informações da vaga
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.business,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _vaga.empresa,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          if (_vaga.localizacao != null || _vaga.tipoContrato != null) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                if (_vaga.localizacao != null)
                                  Chip(
                                    label: Text(_vaga.localizacao!),
                                    avatar: const Icon(Icons.location_on, size: 16),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                if (_vaga.tipoContrato != null)
                                  Chip(
                                    label: Text(_vaga.tipoContrato!),
                                    avatar: const Icon(Icons.business_center, size: 16),
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                          ],
                          if (_vaga.descricao.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              _vaga.descricao,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                          if (_vaga.requisitos.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Requisitos:',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: _vaga.requisitos.map((req) => Chip(
                                    label: Text(
                                      req,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  )).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Botão para ver ranking
                  if (_vaga.curriculosAnexados.any((c) => c.analise != null))
                    Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RankingScreen(vaga: _vaga),
                            ),
                          ).then((_) => _carregarVaga());
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.emoji_events,
                                  color: Colors.amber[700],
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ver Ranking',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Veja os melhores currículos ordenados por compatibilidade',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_vaga.curriculosAnexados.any((c) => c.analise != null))
                    const SizedBox(height: 24),
                  
                  // Seção de currículos anexados
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Currículos Anexados (${_vaga.curriculosAnexados.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (_vaga.curriculosAnexados.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum currículo anexado',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toque no botão abaixo para anexar currículos',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._vaga.curriculosAnexados.map((curriculo) {
                      final arquivoExiste = curriculo.arquivoExiste();
                      final temAnalise = curriculo.analise != null;
                      final estaAnalisando = _isAnalyzing && _curriculoEmAnalise == curriculo.id;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          curriculo.nomeCandidato.isNotEmpty
                                              ? curriculo.nomeCandidato
                                              : 'Candidato',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          curriculo.nomeArquivo,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Anexado em ${_formatarData(curriculo.dataAnexo)}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey[500],
                                                fontSize: 11,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!arquivoExiste)
                                    Chip(
                                      label: const Text('Arquivo não encontrado'),
                                      backgroundColor: Colors.red[100],
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _removerCurriculo(curriculo);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 20, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Remover', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (temAnalise && curriculo.analise != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getScoreColor(curriculo.analise!.compatibilityScore)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Compatibilidade: ${curriculo.analise!.compatibilityScore.toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: _getScoreColor(
                                                  curriculo.analise!.compatibilityScore,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              curriculo.analise!.isSuitable
                                                  ? 'Adequado para a vaga'
                                                  : 'Não adequado para a vaga',
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AnalysisResultScreen(
                                                analysis: curriculo.analise!,
                                                vagaDescription: _vaga.toVagaDescription(),
                                              ),
                                            ),
                                          );
                                        },
                                        tooltip: 'Ver análise completa',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: arquivoExiste && !estaAnalisando
                                          ? () => _analisarCurriculo(curriculo)
                                          : null,
                                      icon: estaAnalisando
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.analytics_outlined),
                                      label: Text(estaAnalisando
                                          ? 'Analisando...'
                                          : temAnalise
                                              ? 'Reanalisar'
                                              : 'Analisar'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _anexarCurriculos,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.attach_file),
        label: Text(_isLoading ? 'Anexando...' : 'Anexar Currículos'),
      ),
    );
  }

  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inDays == 0) {
      if (diferenca.inHours == 0) {
        if (diferenca.inMinutes == 0) {
          return 'Agora';
        }
        return '${diferenca.inMinutes} min atrás';
      }
      return '${diferenca.inHours} h atrás';
    } else if (diferenca.inDays == 1) {
      return 'Ontem';
    } else if (diferenca.inDays < 7) {
      return '${diferenca.inDays} dias atrás';
    } else {
      return '${data.day}/${data.month}/${data.year}';
    }
  }

}

