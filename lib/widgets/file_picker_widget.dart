import 'package:flutter/material.dart';
import 'dart:io';

class FilePickerWidget extends StatelessWidget {
  final File? selectedFile;
  final VoidCallback onFilePicked;
  final VoidCallback? onFileRemoved;

  const FilePickerWidget({
    super.key,
    required this.selectedFile,
    required this.onFilePicked,
    this.onFileRemoved,
  });

  String _getFileName(File file) {
    return file.path.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (selectedFile != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFileName(selectedFile!),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Arquivo selecionado',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (onFileRemoved != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onFileRemoved,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: onFilePicked,
          icon: const Icon(Icons.attach_file),
          label: Text(selectedFile == null
              ? 'Selecionar Currículo (PDF, DOC, DOCX)'
              : 'Trocar Arquivo'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

