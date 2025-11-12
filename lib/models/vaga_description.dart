class VagaDescription {
  final String titulo;
  final String descricao;
  final List<String> requisitos;
  final String empresa;
  final String? localizacao;
  final String? tipoContrato;

  VagaDescription({
    required this.titulo,
    required this.descricao,
    required this.requisitos,
    required this.empresa,
    this.localizacao,
    this.tipoContrato,
  });

  factory VagaDescription.fromJson(Map<String, dynamic> json) {
    return VagaDescription(
      titulo: json['titulo'] as String? ?? '',
      descricao: json['descricao'] as String? ?? '',
      requisitos: (json['requisitos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      empresa: json['empresa'] as String? ?? '',
      localizacao: json['localizacao'] as String?,
      tipoContrato: json['tipoContrato'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'requisitos': requisitos,
      'empresa': empresa,
      'localizacao': localizacao,
      'tipoContrato': tipoContrato,
    };
  }
}

