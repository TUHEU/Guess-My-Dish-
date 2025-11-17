import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerCard extends StatelessWidget {
  final PlatformFile? selectedFile;
  final VoidCallback onPickFile;
  final VoidCallback? onRemoveFile;
  final bool isUploading;

  const FilePickerCard({
    super.key,
    this.selectedFile,
    required this.onPickFile,
    this.onRemoveFile,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select File',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: isUploading ? null : onPickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Choose File (PDF, DOC, DOCX, TXT)'),
            ),
            if (selectedFile != null) ...[
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(
                  Icons.insert_drive_file,
                  color: Colors.blue,
                  size: 32,
                ),
                title: Text(selectedFile!.name),
                subtitle: Text(
                  '${(selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: isUploading ? null : onRemoveFile,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
