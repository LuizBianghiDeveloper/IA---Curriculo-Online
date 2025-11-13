import 'package:flutter/material.dart';
import '../models/vaga.dart';
import '../models/curriculo_anexado.dart';
import 'analysis_result_screen.dart';

class RankingScreen extends StatelessWidget {
  final Vaga vaga;

  const RankingScreen({
    super.key,
    required this.vaga,
  });

  Color _getScoreColor(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
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

  @override
  Widget build(BuildContext context) {
    // Filtra currículos com análise e ordena por score
    final curriculosComAnalise = vaga.curriculosAnexados
        .where((c) => c.analise != null)
        .toList();
    
    if (curriculosComAnalise.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ranking'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum currículo analisado',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Analise os currículos para ver o ranking',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Ordena por score decrescente
    curriculosComAnalise.sort((a, b) {
      final scoreA = a.analise?.compatibilityScore ?? 0.0;
      final scoreB = b.analise?.compatibilityScore ?? 0.0;
      return scoreB.compareTo(scoreA);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header com troféu
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 64,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ranking dos Melhores Currículos',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vaga.titulo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vaga.empresa,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Lista de ranking
            ...curriculosComAnalise.asMap().entries.map((entry) {
              final index = entry.key;
              final curriculo = entry.value;
              final analise = curriculo.analise!;
              final posicao = index + 1;
              final scoreColor = _getScoreColor(analise.compatibilityScore);

              return Container(
                margin: EdgeInsets.only(bottom: index < curriculosComAnalise.length - 1 ? 16 : 0),
                child: Card(
                  elevation: posicao <= 3 ? 4 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: posicao <= 3
                        ? BorderSide(
                            color: _getRankingColor(posicao),
                            width: 2,
                          )
                        : BorderSide.none,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnalysisResultScreen(
                            analysis: analise,
                            vagaDescription: vaga.toVagaDescription(),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: posicao <= 3
                            ? _getRankingColor(posicao).withOpacity(0.05)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // Posição no ranking
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: posicao <= 3
                                  ? _getRankingColor(posicao)
                                  : Colors.grey[300],
                              shape: BoxShape.circle,
                              boxShadow: posicao <= 3
                                  ? [
                                      BoxShadow(
                                        color: _getRankingColor(posicao)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: posicao <= 3
                                  ? Icon(
                                      _getRankingIcon(posicao),
                                      color: Colors.white,
                                      size: 28,
                                    )
                                  : Text(
                                      '$posicao',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Informações do currículo
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  curriculo.nomeCandidato.isNotEmpty
                                      ? curriculo.nomeCandidato
                                      : 'Candidato',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
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
                                            size: 18,
                                            color: scoreColor,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${analise.compatibilityScore.toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: scoreColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (analise.isSuitable)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
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
                                              size: 16,
                                              color: Colors.green[700],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Adequado',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.green[700],
                                                fontWeight: FontWeight.w600,
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
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

