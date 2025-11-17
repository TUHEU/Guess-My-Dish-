import 'package:flutter/material.dart';
import '../models/paper.dart';
import '../models/enums.dart';

class DocumentViewerScreen extends StatelessWidget {
  final Paper paper;

  const DocumentViewerScreen({super.key, required this.paper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(paper.title),
        backgroundColor: Colors.blue.withOpacity(0.8),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloading ${paper.title}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paper.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${paper.subject} • ${paper.levelString} • ${paper.year}'),
                const SizedBox(height: 4),
                Text('Uploaded by: ${paper.uploaderName}'),
                if (paper.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    paper.description!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: _buildDocumentContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getContentTypeIcon(paper.contentType),
            size: 64,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          Text(
            'Document Preview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'File: ${paper.filePath}',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'This is a preview of the document content.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'In a real application, this would display the actual '
                    'content of the ${paper.fileType.toLowerCase()} file '
                    'using a document viewer.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening ${paper.title} in document viewer'),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Document'),
          ),
        ],
      ),
    );
  }

  IconData _getContentTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.pastPaper:
        return Icons.assignment;
      case ContentType.notes:
        return Icons.note;
      case ContentType.answerSheet:
        return Icons.assignment_turned_in;
      case ContentType.quiz:
        return Icons.quiz;
    }
  }
}
