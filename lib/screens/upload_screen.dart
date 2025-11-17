import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/paper.dart';
import '../models/enums.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  PlatformFile? _selectedFile;
  String _selectedSubject = 'Mathematics';
  UniversityLevel _selectedLevel = UniversityLevel.level1;
  String _selectedYear = '2024';
  ContentType _selectedContentType = ContentType.pastPaper;
  String _description = '';
  final List<String> _selectedTags = [];
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final List<String> _subjects = [
    'Mathematics',
    'Biology',
    'Chemistry',
    'Physics',
    'English',
    'Computer Science',
    'Engineering',
    'Medicine',
    'Law',
    'Business'
  ];

  final List<String> _years = ['2024', '2023', '2022', '2021', '2020'];
  final List<String> _popularTags = [
    'final',
    'midterm',
    'lecture-notes',
    'solutions',
    'quiz',
    'exam',
    'homework',
    'lab-report'
  ];

  Future<void> _pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'pnj'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          // Auto-fill title from filename if not already set
          if (_titleController.text.isEmpty) {
            String fileName = _selectedFile!.name;
            if (_selectedFile!.extension != null) {
              fileName =
                  fileName.replaceAll('.${_selectedFile!.extension}', '');
            }
            _titleController.text = fileName;
          }
        });
      }
    } catch (e) {
      _showError('Failed to pick file: $e');
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      _showError('Please select a file first');
      return;
    }

    if (_titleController.text.isEmpty) {
      _showError('Please enter a title for the content');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser!;

    try {
      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        setState(() {
          _uploadProgress = i / 100;
        });
      }

      final newPaper = Paper(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        subject: _selectedSubject,
        level: _selectedLevel,
        year: _selectedYear,
        uploaderId: user.id,
        uploaderName: user.username,
        contentType: _selectedContentType,
        status: 'pending',
        fileType: _selectedFile!.extension?.toUpperCase() ?? 'PDF',
        uploadDate: DateTime.now(),
        description: _description.isEmpty ? null : _description,
        tags: List.from(_selectedTags),
        filePath: _selectedFile!.path ?? 'uploaded/${_selectedFile!.name}',
      );

      appState.addPaper(newPaper);
      _resetForm();
      _showSuccess(
        '${_getContentTypeLabel(_selectedContentType)} uploaded successfully! '
        'It will be available after admin approval.',
      );

      appState.setCurrentTab(0); // Navigate back to dashboard
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        _showError('Upload failed: $e');
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedFile = null;
      _selectedSubject = 'Mathematics';
      _selectedLevel = UniversityLevel.level1;
      _selectedYear = '2024';
      _selectedContentType = ContentType.pastPaper;
      _description = '';
      _selectedTags.clear();
      _isUploading = false;
      _uploadProgress = 0.0;
    });
    _titleController.clear();
    _tagController.clear();
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim().toLowerCase();
    if (trimmedTag.isNotEmpty && !_selectedTags.contains(trimmedTag)) {
      setState(() {
        _selectedTags.add(trimmedTag);
      });
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _tagController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Educational Content',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 20),
          _buildContentTypeSection(),
          const SizedBox(height: 16),
          _buildFileSelectionSection(),
          const SizedBox(height: 16),
          _buildContentDetailsSection(),
          const SizedBox(height: 16),
          _buildUploadProgressSection(),
          const SizedBox(height: 16),
          _buildUploadButton(),
        ],
      ),
    );
  }

  Widget _buildContentTypeSection() {
    return Card(
      color: Colors.white.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Content Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ContentType.values.map((type) {
                return FilterChip(
                  label: Text(_getContentTypeLabel(type)),
                  selected: _selectedContentType == type,
                  onSelected: (selected) {
                    setState(() => _selectedContentType = type);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectionSection() {
    return Card(
      color: Colors.white.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '2. Select File',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Choose File (PDF, DOC, DOCX, TXT, PNJ)'),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(
                  Icons.insert_drive_file,
                  color: Colors.blue,
                  size: 32,
                ),
                title: Text(_selectedFile!.name),
                subtitle: Text(
                  '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _isUploading
                      ? null
                      : () => setState(() => _selectedFile = null),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContentDetailsSection() {
    return Card(
      color: Colors.white.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '3. Content Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
                hintText: 'Enter a descriptive title for your content',
              ),
              readOnly: _isUploading,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              items: _subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
              onChanged: _isUploading
                  ? null
                  : (value) {
                      setState(() => _selectedSubject = value!);
                    },
              decoration: const InputDecoration(
                labelText: 'Subject *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'University Level *',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: UniversityLevel.values.map((level) {
                    return FilterChip(
                      label: Text(_getLevelLabel(level)),
                      selected: _selectedLevel == level,
                      onSelected: _isUploading
                          ? null
                          : (selected) {
                              setState(() => _selectedLevel = level);
                            },
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedYear,
              items: _years.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
              onChanged: _isUploading
                  ? null
                  : (value) {
                      setState(() => _selectedYear = value!);
                    },
              decoration: const InputDecoration(
                labelText: 'Year *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tags',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                if (_selectedTags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _selectedTags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                        deleteIcon: const Icon(Icons.close, size: 16),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _popularTags.map((tag) {
                    return FilterChip(
                      label: Text(tag),
                      selected: _selectedTags.contains(tag),
                      onSelected: _isUploading
                          ? null
                          : (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTags.add(tag);
                                } else {
                                  _selectedTags.remove(tag);
                                }
                              });
                            },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        decoration: const InputDecoration(
                          labelText: 'Add custom tag',
                          border: OutlineInputBorder(),
                          hintText: 'Press enter to add tag',
                        ),
                        onSubmitted: _addTag,
                        readOnly: _isUploading,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _isUploading
                          ? null
                          : () => _addTag(_tagController.text),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Describe your content...',
              ),
              onChanged: _isUploading ? null : (value) => _description = value,
              readOnly: _isUploading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProgressSection() {
    if (!_isUploading) return const SizedBox.shrink();

    return Card(
      color: Colors.white.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: _uploadProgress),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(_uploadProgress * 100).toStringAsFixed(0)}%'),
                Text(
                  _uploadProgress >= 1.0 ? 'Processing...' : 'Uploading...',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton.icon(
      onPressed: _isUploading ? null : _uploadFile,
      icon: _isUploading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.cloud_upload),
      label: Text(
        _isUploading
            ? 'Uploading...'
            : 'Upload ${_getContentTypeLabel(_selectedContentType)}',
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  String _getContentTypeLabel(ContentType type) {
    switch (type) {
      case ContentType.pastPaper:
        return 'Past Paper';
      case ContentType.notes:
        return 'Study Notes';
      case ContentType.answerSheet:
        return 'Answer Sheet';
      case ContentType.quiz:
        return 'Quiz';
    }
  }

  String _getLevelLabel(UniversityLevel level) {
    switch (level) {
      case UniversityLevel.level1:
        return 'Level 1';
      case UniversityLevel.level2:
        return 'Level 2';
      case UniversityLevel.level3:
        return 'Level 3';
      case UniversityLevel.level4:
        return 'Level 4';
    }
  }
}
