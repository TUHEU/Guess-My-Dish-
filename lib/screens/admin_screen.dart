import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/paper.dart';
import '../models/enums.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  void _showRejectionDialog(BuildContext context, String paperId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Paper'),
        content: TextField(
          controller: reasonController,
          decoration:
              const InputDecoration(hintText: 'Reason for rejection...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Provider.of<AppState>(context, listen: false)
                    .rejectPaper(paperId, reasonController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final pendingPapers = appState.uploadedPapers
            .where((p) => p.status == 'pending')
            .toList();

        return pendingPapers.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'No papers pending review 🎉',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      color: Colors.amber.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber,
                                color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${pendingPapers.length} papers awaiting approval',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pendingPapers.length,
                      itemBuilder: (context, index) {
                        final paper = pendingPapers[index];
                        return _buildPendingPaperCard(context, paper, appState);
                      },
                    ),
                  ),
                ],
              );
      },
    );
  }

  Widget _buildPendingPaperCard(
      BuildContext context, Paper paper, AppState appState) {
    return Card(
      color: Colors.white.withOpacity(0.85),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLevelColor(paper.level),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(paper.levelString,
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
              const SizedBox(width: 8),
              Text(paper.contentTypeString,
                  style: TextStyle(
                      color: _getContentTypeColor(paper.contentType),
                      fontSize: 12)),
            ]),
            const SizedBox(height: 12),
            Text(paper.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${paper.subject} • ${paper.year}',
                style: const TextStyle(color: Colors.grey)),
            if (paper.description != null) ...[
              const SizedBox(height: 8),
              Text(paper.description!),
            ],
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(paper.uploaderName,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Spacer(),
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${paper.uploadDate.day}/${paper.uploadDate.month}/${paper.uploadDate.year}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRejectionDialog(context, paper.id),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => appState.approvePaper(paper.id),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(UniversityLevel level) {
    switch (level) {
      case UniversityLevel.level1:
        return Colors.blue;
      case UniversityLevel.level2:
        return Colors.green;
      case UniversityLevel.level3:
        return Colors.orange;
      case UniversityLevel.level4:
        return Colors.purple;
    }
  }

  Color _getContentTypeColor(ContentType type) {
    switch (type) {
      case ContentType.pastPaper:
        return Colors.blue;
      case ContentType.notes:
        return Colors.green;
      case ContentType.answerSheet:
        return Colors.orange;
      case ContentType.quiz:
        return Colors.purple;
    }
  }
}
