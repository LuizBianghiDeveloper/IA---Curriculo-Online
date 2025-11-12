import 'vaga_description.dart';
import 'curriculo_anexado.dart';

class Vaga {
  final String id;
  final String titulo;
  final String descricao;
  final List<String> requisitos;
  final String empresa;
  final String? localizacao;
  final String? tipoContrato;
  final DateTime dataCriacao;
  final DateTime? dataAtualizacao;
  final List<CurriculoAnexado> curriculosAnexados;

  Vaga({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.requisitos,
    required this.empresa,
    this.localizacao,
    this.tipoContrato,
    required this.dataCriacao,
    this.dataAtualizacao,
    List<CurriculoAnexado>? curriculosAnexados,
  }) : curriculosAnexados = curriculosAnexados ?? [];

  factory Vaga.fromJson(Map<String, dynamic> json) {
    return Vaga(
      id: json['id'] as String,
      titulo: json['titulo'] as String? ?? '',
      descricao: json['descricao'] as String? ?? '',
      requisitos: (json['requisitos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      empresa: json['empresa'] as String? ?? '',
      localizacao: json['localizacao'] as String?,
      tipoContrato: json['tipoContrato'] as String?,
      dataCriacao: json['dataCriacao'] != null
          ? DateTime.parse(json['dataCriacao'] as String)
          : DateTime.now(),
      dataAtualizacao: json['dataAtualizacao'] != null
          ? DateTime.parse(json['dataAtualizacao'] as String)
          : null,
      curriculosAnexados: (json['curriculosAnexados'] as List<dynamic>?)
              ?.map((e) => CurriculoAnexado.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'requisitos': requisitos,
      'empresa': empresa,
      'localizacao': localizacao,
      'tipoContrato': tipoContrato,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataAtualizacao': dataAtualizacao?.toIso8601String(),
      'curriculosAnexados': curriculosAnexados.map((c) => c.toJson()).toList(),
    };
  }

  // Converte para VagaDescription (usado na análise)
  VagaDescription toVagaDescription() {
    return VagaDescription(
      titulo: titulo,
      descricao: descricao,
      requisitos: requisitos,
      empresa: empresa,
      localizacao: localizacao,
      tipoContrato: tipoContrato,
    );
  }

  // Cria uma cópia com campos atualizados
  Vaga copyWith({
    String? id,
    String? titulo,
    String? descricao,
    List<String>? requisitos,
    String? empresa,
    String? localizacao,
    String? tipoContrato,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
    List<CurriculoAnexado>? curriculosAnexados,
  }) {
    return Vaga(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      requisitos: requisitos ?? this.requisitos,
      empresa: empresa ?? this.empresa,
      localizacao: localizacao ?? this.localizacao,
      tipoContrato: tipoContrato ?? this.tipoContrato,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      curriculosAnexados: curriculosAnexados ?? this.curriculosAnexados,
    );
  }
}

