import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/vaga.dart';
import '../models/curriculo_anexado.dart';
import '../services/vaga_service.dart';
import '../services/api_service.dart';
import 'analysis_result_screen.dart';

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
                  
                  // Seção de Ranking
                  _buildRankingSection(context),
                  
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

  Widget _buildRankingSection(BuildContext context) {
    // Filtra currículos com análise e ordena por score
    final curriculosComAnalise = _vaga.curriculosAnexados
        .where((c) => c.analise != null)
        .toList();
    
    if (curriculosComAnalise.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ordena por score decrescente
    curriculosComAnalise.sort((a, b) {
      final scoreA = a.analise?.compatibilityScore ?? 0.0;
      final scoreB = b.analise?.compatibilityScore ?? 0.0;
      return scoreB.compareTo(scoreA);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.amber[700],
            ),
            const SizedBox(width: 8),
            Text(
              'Ranking dos Melhores Currículos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: curriculosComAnalise.asMap().entries.map((entry) {
                final index = entry.key;
                final curriculo = entry.value;
                final analise = curriculo.analise!;
                final posicao = index + 1;
                final scoreColor = _getScoreColor(analise.compatibilityScore);

                return Container(
                  margin: EdgeInsets.only(bottom: index < curriculosComAnalise.length - 1 ? 12 : 0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnalysisResultScreen(
                            analysis: analise,
                            vagaDescription: _vaga.toVagaDescription(),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: posicao <= 3
                            ? _getRankingColor(posicao).withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: posicao <= 3
                            ? Border.all(
                                color: _getRankingColor(posicao),
                                width: 2,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Posição no ranking
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: posicao <= 3
                                  ? _getRankingColor(posicao)
                                  : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: posicao <= 3
                                  ? Icon(
                                      _getRankingIcon(posicao),
                                      color: Colors.white,
                                      size: 24,
                                    )
                                  : Text(
                                      '$posicao',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Informações do currículo
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  curriculo.nomeArquivo,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: scoreColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 16,
                                            color: scoreColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${analise.compatibilityScore.toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: scoreColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (analise.isSuitable)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              size: 14,
                                              color: Colors.green[700],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Adequado',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.green[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Ícone de visualizar
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Color _getRankingColor(int posicao) {
    switch (posicao) {
      case 1:
        return Colors.amber; // Ouro
      case 2:
        return Colors.grey[400]!; // Prata
      case 3:
        return Colors.brown[300]!; // Bronze
      default:
        return Colors.grey[300]!;
    }
  }

  IconData _getRankingIcon(int posicao) {
    switch (posicao) {
      case 1:
        return Icons.looks_one; // 1º lugar
      case 2:
        return Icons.looks_two; // 2º lugar
      case 3:
        return Icons.looks_3; // 3º lugar
      default:
        return Icons.circle;
    }
  }
}

