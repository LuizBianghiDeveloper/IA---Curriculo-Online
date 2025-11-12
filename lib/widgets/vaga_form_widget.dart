import 'package:flutter/material.dart';
import '../models/vaga_description.dart';

class VagaFormWidget extends StatefulWidget {
  final Function(VagaDescription) onVagaChanged;

  const VagaFormWidget({
    super.key,
    required this.onVagaChanged,
  });

  @override
  State<VagaFormWidget> createState() => _VagaFormWidgetState();
}

class _VagaFormWidgetState extends State<VagaFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _empresaController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _requisitoController = TextEditingController();
  final List<String> _requisitos = [];
  String? _localizacao;
  String? _tipoContrato;

  void _addRequisito() {
    if (_requisitoController.text.trim().isNotEmpty) {
      setState(() {
        _requisitos.add(_requisitoController.text.trim());
        _requisitoController.clear();
      });
      _updateVaga();
    }
  }

  void _removeRequisito(int index) {
    setState(() {
      _requisitos.removeAt(index);
    });
    _updateVaga();
  }

  void _updateVaga() {
    if (_formKey.currentState?.validate() ?? false) {
      final vaga = VagaDescription(
        titulo: _tituloController.text.trim(),
        empresa: _empresaController.text.trim(),
        descricao: _descricaoController.text.trim(),
        requisitos: List.from(_requisitos),
        localizacao: _localizacao,
        tipoContrato: _tipoContrato,
      );
      widget.onVagaChanged(vaga);
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _empresaController.dispose();
    _descricaoController.dispose();
    _requisitoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: _updateVaga,
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
                return 'Campo obrigatório';
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
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Tipo de Contrato',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            value: _tipoContrato,
            items: const [
              DropdownMenuItem(value: null, child: Text('Não especificado')),
              DropdownMenuItem(value: 'CLT', child: Text('CLT')),
              DropdownMenuItem(value: 'PJ', child: Text('PJ')),
              DropdownMenuItem(value: 'Estágio', child: Text('Estágio')),
              DropdownMenuItem(value: 'Freelance', child: Text('Freelance')),
            ],
            onChanged: (value) {
              setState(() {
                _tipoContrato = value;
              });
              _updateVaga();
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descricaoController,
            decoration: const InputDecoration(
              labelText: 'Descrição da Vaga *',
              hintText: 'Descreva as responsabilidades e características da vaga',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
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
                    hintText: 'Ex: 3 anos de experiência em Flutter',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (_) => _addRequisito(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addRequisito,
                icon: const Icon(Icons.add),
                tooltip: 'Adicionar',
              ),
            ],
          ),
          if (_requisitos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                _requisitos.length,
                (index) => Chip(
                  label: Text(_requisitos[index]),
                  onDeleted: () => _removeRequisito(index),
                  deleteIcon: const Icon(Icons.close, size: 18),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

