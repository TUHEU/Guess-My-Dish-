import 'package:flutter/material.dart';
import '../../models/paper.dart';
import '../../models/enums.dart';

class PaperCard extends StatelessWidget {
  final Paper paper;
  final VoidCallback? onTap;
  final bool showActions;

  const PaperCard({
    super.key,
    required this.paper,
    this.onTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.85),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with level and type
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getLevelColor(paper.level).withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      paper.levelString,
                      style: TextStyle(
                        color: _getLevelColor(paper.level),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color:
                          _getContentTypeColor(paper.contentType).withAlpha(40),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      _getContentTypeIcon(paper.contentType),
                      color: _getContentTypeColor(paper.contentType),
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                paper.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              // Subject and year
              Text(
                '${paper.subject} • ${paper.year}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              // Description
              if (paper.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  paper.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              // Tags
              if (paper.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      label: Text(paper.fileType),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    ...paper.tags.take(2).map((tag) {
                      return Chip(
                        label: Text(tag),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }),
                  ],
                ),
              const SizedBox(height: 12),
              // Footer with uploader info and download count
              Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    child: Icon(Icons.person, size: 12),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      paper.uploaderName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const Icon(Icons.download, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${paper.downloadCount}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              // Action button
              if (showActions && onTap != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Document'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
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
