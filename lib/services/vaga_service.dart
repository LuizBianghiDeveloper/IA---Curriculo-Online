import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vaga.dart';
import '../models/curriculo_anexado.dart';
import '../models/curriculo_analysis.dart';

class VagaService {
  static const String _vagasKey = 'vagas_list';

  /// Salva uma nova vaga
  static Future<Vaga> criarVaga({
    required String titulo,
    required String descricao,
    required List<String> requisitos,
    required String empresa,
    String? localizacao,
    String? tipoContrato,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final vagas = await listarVagas();
    
    final novaVaga = Vaga(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo,
      descricao: descricao,
      requisitos: requisitos,
      empresa: empresa,
      localizacao: localizacao,
      tipoContrato: tipoContrato,
      dataCriacao: DateTime.now(),
    );

    vagas.add(novaVaga);
    await _salvarVagas(vagas);
    
    return novaVaga;
  }

  /// Atualiza uma vaga existente
  static Future<Vaga> atualizarVaga(Vaga vaga) async {
    final prefs = await SharedPreferences.getInstance();
    final vagas = await listarVagas();
    
    final index = vagas.indexWhere((v) => v.id == vaga.id);
    if (index == -1) {
      throw Exception('Vaga não encontrada');
    }

    final vagaAtualizada = vaga.copyWith(
      dataAtualizacao: DateTime.now(),
    );

    vagas[index] = vagaAtualizada;
    await _salvarVagas(vagas);
    
    return vagaAtualizada;
  }

  /// Exclui uma vaga
  static Future<void> excluirVaga(String id) async {
    final vagas = await listarVagas();
    vagas.removeWhere((v) => v.id == id);
    await _salvarVagas(vagas);
  }

  /// Lista todas as vagas
  static Future<List<Vaga>> listarVagas() async {
    final prefs = await SharedPreferences.getInstance();
    final vagasJson = prefs.getString(_vagasKey);
    
    if (vagasJson == null || vagasJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(vagasJson);
      return jsonList.map((json) => Vaga.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Busca uma vaga por ID
  static Future<Vaga?> buscarVagaPorId(String id) async {
    final vagas = await listarVagas();
    try {
      return vagas.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Anexa um currículo a uma vaga
  static Future<Vaga> anexarCurriculo({
    required String vagaId,
    required String caminhoArquivo,
    required String nomeArquivo,
    required String nomeCandidato,
  }) async {
    final vagas = await listarVagas();
    final index = vagas.indexWhere((v) => v.id == vagaId);
    
    if (index == -1) {
      throw Exception('Vaga não encontrada');
    }

    final vaga = vagas[index];
    final curriculoAnexado = CurriculoAnexado(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nomeArquivo: nomeArquivo,
      caminhoArquivo: caminhoArquivo,
      nomeCandidato: nomeCandidato,
      dataAnexo: DateTime.now(),
    );

    final curriculosAtualizados = List<CurriculoAnexado>.from(vaga.curriculosAnexados);
    curriculosAtualizados.add(curriculoAnexado);

    final vagaAtualizada = vaga.copyWith(
      curriculosAnexados: curriculosAtualizados,
      dataAtualizacao: DateTime.now(),
    );

    vagas[index] = vagaAtualizada;
    await _salvarVagas(vagas);
    
    return vagaAtualizada;
  }

  /// Remove um currículo anexado de uma vaga
  static Future<Vaga> removerCurriculo({
    required String vagaId,
    required String curriculoId,
  }) async {
    final vagas = await listarVagas();
    final index = vagas.indexWhere((v) => v.id == vagaId);
    
    if (index == -1) {
      throw Exception('Vaga não encontrada');
    }

    final vaga = vagas[index];
    final curriculosAtualizados = List<CurriculoAnexado>.from(vaga.curriculosAnexados);
    curriculosAtualizados.removeWhere((c) => c.id == curriculoId);

    final vagaAtualizada = vaga.copyWith(
      curriculosAnexados: curriculosAtualizados,
      dataAtualizacao: DateTime.now(),
    );

    vagas[index] = vagaAtualizada;
    await _salvarVagas(vagas);
    
    return vagaAtualizada;
  }

  /// Atualiza a análise de um currículo anexado
  static Future<Vaga> atualizarAnaliseCurriculo({
    required String vagaId,
    required String curriculoId,
    required CurriculoAnalysis analise,
  }) async {
    final vagas = await listarVagas();
    final index = vagas.indexWhere((v) => v.id == vagaId);
    
    if (index == -1) {
      throw Exception('Vaga não encontrada');
    }

    final vaga = vagas[index];
    final curriculosAtualizados = vaga.curriculosAnexados.map((c) {
      if (c.id == curriculoId) {
        return c.copyWith(analise: analise);
      }
      return c;
    }).toList();

    final vagaAtualizada = vaga.copyWith(
      curriculosAnexados: curriculosAtualizados,
      dataAtualizacao: DateTime.now(),
    );

    vagas[index] = vagaAtualizada;
    await _salvarVagas(vagas);
    
    return vagaAtualizada;
  }

  /// Salva a lista de vagas no SharedPreferences
  static Future<void> _salvarVagas(List<Vaga> vagas) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = vagas.map((v) => v.toJson()).toList();
    await prefs.setString(_vagasKey, jsonEncode(jsonList));
  }
}

