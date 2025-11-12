import 'dart:io';
import 'curriculo_analysis.dart';

class CurriculoAnexado {
  final String id;
  final String nomeArquivo;
  final String caminhoArquivo;
  final String nomeCandidato;
  final DateTime dataAnexo;
  final CurriculoAnalysis? analise;

  CurriculoAnexado({
    required this.id,
    required this.nomeArquivo,
    required this.caminhoArquivo,
    required this.nomeCandidato,
    required this.dataAnexo,
    this.analise,
  });

  factory CurriculoAnexado.fromJson(Map<String, dynamic> json) {
    return CurriculoAnexado(
      id: json['id'] as String,
      nomeArquivo: json['nomeArquivo'] as String? ?? '',
      caminhoArquivo: json['caminhoArquivo'] as String? ?? '',
      nomeCandidato: json['nomeCandidato'] as String? ?? '',
      dataAnexo: json['dataAnexo'] != null
          ? DateTime.parse(json['dataAnexo'] as String)
          : DateTime.now(),
      analise: json['analise'] != null
          ? CurriculoAnalysis.fromJson(json['analise'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomeArquivo': nomeArquivo,
      'caminhoArquivo': caminhoArquivo,
      'nomeCandidato': nomeCandidato,
      'dataAnexo': dataAnexo.toIso8601String(),
      'analise': analise?.toJson(),
    };
  }

  // Verifica se o arquivo ainda existe
  bool arquivoExiste() {
    try {
      final file = File(caminhoArquivo);
      return file.existsSync();
    } catch (e) {
      return false;
    }
  }

  // Obtém o arquivo
  File? obterArquivo() {
    try {
      final file = File(caminhoArquivo);
      if (file.existsSync()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Cria uma cópia com análise atualizada
  CurriculoAnexado copyWith({
    String? id,
    String? nomeArquivo,
    String? caminhoArquivo,
    String? nomeCandidato,
    DateTime? dataAnexo,
    CurriculoAnalysis? analise,
  }) {
    return CurriculoAnexado(
      id: id ?? this.id,
      nomeArquivo: nomeArquivo ?? this.nomeArquivo,
      caminhoArquivo: caminhoArquivo ?? this.caminhoArquivo,
      nomeCandidato: nomeCandidato ?? this.nomeCandidato,
      dataAnexo: dataAnexo ?? this.dataAnexo,
      analise: analise ?? this.analise,
    );
  }
}

