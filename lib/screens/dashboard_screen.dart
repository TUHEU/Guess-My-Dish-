import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/paper.dart';
import '../models/user.dart'; // ADD THIS IMPORT
import '../models/enums.dart';
import 'document_viewer_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.currentUser!;
        final approvedCount = appState.papers.length;
        final pendingCount =
            appState.uploadedPapers.where((p) => p.status == 'pending').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserProfileCard(context, user),
              const SizedBox(height: 20),
              _buildQuickStatsSection(
                  context, approvedCount, pendingCount, user.isAdmin),
              const SizedBox(height: 20),
              _buildQuickActionsSection(context, user.isAdmin, appState),
              const SizedBox(height: 20),
              _buildRecentPapersSection(context, appState.papers),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserProfileCard(BuildContext context, User user) {
    return Card(
      color: Colors.white.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: user.isAdmin ? Colors.amber : Colors.blue,
              child: Icon(
                user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user.username}!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.isAdmin ? 'Administrator' : 'University Student',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.emoji_events, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${user.contributionPoints} Contribution Points',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (user.isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection(
      BuildContext context, int approvedCount, int pendingCount, bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              context,
              'Total Papers',
              approvedCount.toString(),
              Icons.library_books,
              Colors.blue,
            ),
            const SizedBox(width: 12),
            if (isAdmin)
              _buildStatCard(
                context,
                'Pending',
                pendingCount.toString(),
                Icons.pending,
                Colors.orange,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: Colors.white.withOpacity(0.85),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(
      BuildContext context, bool isAdmin, AppState appState) {
    return Card(
      color: Colors.white.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _navigateToUpload(appState),
              icon: const Icon(Icons.upload),
              label: const Text('Upload New Content'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _navigateToLibrary(appState),
              icon: const Icon(Icons.search),
              label: const Text('Browse Library'),
            ),
            if (isAdmin) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _navigateToAdmin(appState),
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Admin Panel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPapersSection(BuildContext context, List<Paper> papers) {
    return Card(
      color: Colors.white.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Community Papers',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (papers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No papers available yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...papers.take(3).map((paper) => _buildPaperItem(context, paper)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaperItem(BuildContext context, Paper paper) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getContentTypeIcon(paper.contentType),
          color: _getContentTypeColor(paper.contentType),
        ),
        title: Text('${paper.subject} - ${paper.levelString}'),
        subtitle: Text('${paper.year} • ${paper.uploaderName}'),
        trailing: Chip(
          label: Text(paper.fileType),
          visualDensity: VisualDensity.compact,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentViewerScreen(paper: paper),
            ),
          );
        },
      ),
    );
  }

  void _navigateToUpload(AppState appState) {
    appState.setCurrentTab(1);
  }

  void _navigateToLibrary(AppState appState) {
    appState.setCurrentTab(2);
  }

  void _navigateToAdmin(AppState appState) {
    appState.setCurrentTab(3);
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
