import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

// ========== ENUMS & MODELS ==========
enum ContentType {
  pastPaper,
  notes,
  answerSheet,
  quiz,
}

enum UniversityLevel {
  level1,
  level2,
  level3,
  level4,
}

class User {
  final String id;
  final String username;
  final String email;
  final bool isAdmin;
  final int contributionPoints;
  final DateTime joinDate;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isAdmin,
    this.contributionPoints = 0,
    required this.joinDate,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    bool? isAdmin,
    int? contributionPoints,
    DateTime? joinDate,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
      contributionPoints: contributionPoints ?? this.contributionPoints,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}

class Paper {
  final String id;
  final String title;
  final String subject;
  final UniversityLevel level;
  final String year;
  final String uploaderId;
  final String uploaderName;
  final ContentType contentType;
  String status;
  final String fileType;
  final DateTime uploadDate;
  final String? description;
  final List<String> tags;
  final int downloadCount;
  String? rejectionReason;

  Paper({
    required this.id,
    required this.title,
    required this.subject,
    required this.level,
    required this.year,
    required this.uploaderId,
    required this.uploaderName,
    required this.contentType,
    required this.status,
    required this.fileType,
    required this.uploadDate,
    this.description,
    this.tags = const [],
    this.downloadCount = 0,
    this.rejectionReason,
  });

  String get levelString {
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

  String get contentTypeString {
    switch (contentType) {
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
}

// ========== AUTHENTICATION SERVICE ==========
class AuthService {
  // Mock user database - in real app, this would connect to a backend
  final List<User> _users = [
    User(
      id: 'admin1',
      username: 'admin',
      email: 'admin@edupapers.com',
      isAdmin: true,
      contributionPoints: 1000,
      joinDate: DateTime(2023, 1, 1),
    ),
    User(
      id: 'student123',
      username: 'john_doe',
      email: 'john@university.edu',
      isAdmin: false,
      contributionPoints: 150,
      joinDate: DateTime(2023, 9, 1),
    ),
    User(
      id: 'student456',
      username: 'sarah_johnson',
      email: 'sarah@university.edu',
      isAdmin: false,
      contributionPoints: 200,
      joinDate: DateTime(2023, 8, 15),
    ),
  ];

  User? login(String username, String password) {
    // Mock authentication - in real app, verify password with backend
    if (password.isEmpty) return null;

    return _users.firstWhere(
      (user) => user.username == username,
      orElse: () => throw Exception('User not found'),
    );
  }

  User? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }
}

// ========== APP STATE MANAGEMENT ==========
class AppState with ChangeNotifier {
  final List<Paper> _papers = [];
  final List<Paper> _uploadedPapers = [];
  User? _currentUser;
  bool _isOffline = false;
  final AuthService _authService = AuthService();

  List<Paper> get papers =>
      _papers.where((p) => p.status == 'approved').toList();
  List<Paper> get uploadedPapers => _uploadedPapers;
  User? get currentUser => _currentUser;
  bool get isOffline => _isOffline;
  bool get isLoggedIn => _currentUser != null;

  AppState() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _papers.addAll([
      Paper(
        id: '1',
        title: 'Mathematics Final Exam',
        subject: 'Mathematics',
        level: UniversityLevel.level1,
        year: '2023',
        uploaderId: 'teacher1',
        uploaderName: 'Dr. Smith',
        contentType: ContentType.pastPaper,
        status: 'approved',
        fileType: 'PDF',
        uploadDate: DateTime(2024, 1, 15),
        description: 'Comprehensive final exam covering all topics',
        tags: ['final', 'comprehensive', 'calculus'],
        downloadCount: 45,
      ),
      Paper(
        id: '2',
        title: 'Biology Study Notes',
        subject: 'Biology',
        level: UniversityLevel.level2,
        year: '2023',
        uploaderId: 'student456',
        uploaderName: 'Sarah Johnson',
        contentType: ContentType.notes,
        status: 'approved',
        fileType: 'PDF',
        uploadDate: DateTime(2024, 1, 10),
        description: 'Detailed notes from Biology 201 lectures',
        tags: ['lecture-notes', 'cell-biology'],
        downloadCount: 89,
      ),
    ]);

    // Don't auto-login anymore - user must login through the login screen
  }

  Future<bool> login(String username, String password) async {
    try {
      final user = _authService.login(username, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void switchToAdmin() {
    _currentUser = _authService.getUserById('admin1');
    notifyListeners();
  }

  void switchToStudent() {
    _currentUser = _authService.getUserById('student123');
    notifyListeners();
  }

  void addPaper(Paper paper) {
    _uploadedPapers.add(paper);
    notifyListeners();
  }

  void approvePaper(String paperId) {
    final paperIndex = _uploadedPapers.indexWhere((p) => p.id == paperId);
    if (paperIndex != -1) {
      final paper = _uploadedPapers[paperIndex];
      paper.status = 'approved';
      _papers.add(paper);
      _uploadedPapers.removeAt(paperIndex);
      notifyListeners();
    }
  }

  void rejectPaper(String paperId, String reason) {
    final paperIndex = _uploadedPapers.indexWhere((p) => p.id == paperId);
    if (paperIndex != -1) {
      final paper = _uploadedPapers[paperIndex];
      paper.status = 'rejected';
      paper.rejectionReason = reason;
      notifyListeners();
    }
  }

  void toggleOfflineMode() {
    _isOffline = !_isOffline;
    notifyListeners();
  }
}

// ========== LOGIN SCREEN ==========
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  // Demo accounts for easy testing
  final List<Map<String, String>> _demoAccounts = [
    {'username': 'admin', 'password': 'admin123', 'role': 'Administrator'},
    {'username': 'john_doe', 'password': 'student123', 'role': 'Student'},
    {'username': 'sarah_johnson', 'password': 'student456', 'role': 'Student'},
  ];

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final success = await Provider.of<AppState>(context, listen: false)
          .login(_usernameController.text.trim(), _passwordController.text);

      setState(() {
        _isLoading = false;
      });

      if (!success) {
        setState(() {
          _errorMessage = 'Invalid username or password';
        });
      }
    }
  }

  void _useDemoAccount(String username, String password) {
    setState(() {
      _usernameController.text = username;
      _passwordController.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Dark Overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Login Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Title
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.school,
                            size: 64,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'PaperLink',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                          ),
                          Text(
                            'Educational Resource Platform',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Login Form
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              'Sign In',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 24),
                            if (_errorMessage.isNotEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  border: Border.all(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage,
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (_errorMessage.isNotEmpty)
                              const SizedBox(height: 16),
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : ElevatedButton(
                                      onPressed: _login,
                                      child: const Text('Sign In'),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Demo Accounts
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demo Accounts',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          ..._demoAccounts.map((account) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: OutlinedButton(
                                onPressed: () => _useDemoAccount(
                                  account['username']!,
                                  account['password']!,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(account['username']!),
                                    Chip(
                                      label: Text(account['role']!),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// ========== DASHBOARD SCREEN ==========
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
              Card(
                color: Colors.white.withOpacity(0.85),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            user.isAdmin ? Colors.amber : Colors.blue,
                        child: Icon(
                          user.isAdmin
                              ? Icons.admin_panel_settings
                              : Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back, ${user.username}!'),
                            const SizedBox(height: 4),
                            Text(user.isAdmin
                                ? 'Administrator'
                                : 'University Student'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.emoji_events,
                                    size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                    '${user.contributionPoints} Contribution Points',
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (user.isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
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
              ),
              const SizedBox(height: 20),
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
                      Colors.blue),
                  const SizedBox(width: 12),
                  _buildStatCard(context, 'Pending', pendingCount.toString(),
                      Icons.pending, Colors.orange),
                ],
              ),
              const SizedBox(height: 20),
              Card(
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
                        onPressed: () => _navigateToUpload(context),
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload New Content'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _navigateToLibrary(context),
                        icon: const Icon(Icons.search),
                        label: const Text('Browse Library'),
                      ),
                      if (user.isAdmin) ...[
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToAdmin(context),
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text('Admin Panel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
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
                      ...appState.papers
                          .take(3)
                          .map((paper) => _buildPaperItem(context, paper)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(title, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaperItem(BuildContext context, Paper paper) {
    return ListTile(
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
    );
  }

  void _navigateToUpload(BuildContext context) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeState != null) {
      homeState.changeIndex(1);
    }
  }

  void _navigateToLibrary(BuildContext context) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeState != null) {
      homeState.changeIndex(2);
    }
  }

  void _navigateToAdmin(BuildContext context) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeState != null) {
      homeState.changeIndex(3);
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

// ========== UPLOAD SCREEN ==========
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
    'solutions'
  ];

  Future<void> _pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
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

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser!;

    try {
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        setState(() {
          _uploadProgress = i / 100;
        });
      }

      final newPaper = Paper(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title:
            _selectedFile!.name.replaceAll('.${_selectedFile!.extension}', ''),
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
      );

      appState.addPaper(newPaper);
      _resetForm();
      _showSuccess(
          '${_getContentTypeLabel(_selectedContentType)} uploaded successfully!');

      if (mounted) {
        final homeState = context.findAncestorStateOfType<_HomeScreenState>();
        if (homeState != null) {
          homeState.changeIndex(0);
        }
      }
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
      _description = '';
      _selectedTags.clear();
      _isUploading = false;
      _uploadProgress = 0.0;
    });
    _tagController.clear();
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_selectedTags.contains(trimmedTag)) {
      setState(() {
        _selectedTags.add(trimmedTag);
      });
      _tagController.clear();
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
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
          Card(
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
          ),
          const SizedBox(height: 16),
          Card(
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
                    label: const Text('Choose File (PDF, DOC)'),
                  ),
                  if (_selectedFile != null) ...[
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.insert_drive_file,
                          color: Colors.blue, size: 32),
                      title: Text(_selectedFile!.name),
                      subtitle: Text(
                          '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB'),
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
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white.withOpacity(0.85),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '3. University Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSubject,
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
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('University Level',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: UniversityLevel.values.map((level) {
                          return FilterChip(
                            label: Text(_getLevelLabel(level)),
                            selected: _selectedLevel == level,
                            onSelected: (selected) {
                              setState(() => _selectedLevel = level);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedYear,
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
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tags',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
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
                              ),
                              onSubmitted: _addTag,
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
                    ),
                    onChanged:
                        _isUploading ? null : (value) => _description = value,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isUploading) ...[
            Card(
              color: Colors.white.withOpacity(0.85),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload Progress',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: _uploadProgress),
                    const SizedBox(height: 8),
                    Text('${(_uploadProgress * 100).toStringAsFixed(0)}%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _uploadFile,
            icon: _isUploading
                ? const CircularProgressIndicator()
                : const Icon(Icons.cloud_upload),
            label: Text(_isUploading
                ? 'Uploading...'
                : 'Upload ${_getContentTypeLabel(_selectedContentType)}'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
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

// ========== LIBRARY SCREEN ==========
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final papers = appState.papers;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search papers, notes, answers...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.85),
                ),
              ),
            ),
            Expanded(
              child: papers.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.white),
                          SizedBox(height: 16),
                          Text('No papers found',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: papers.length,
                      itemBuilder: (context, index) {
                        final paper = papers[index];
                        return _buildPaperCard(context, paper);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaperCard(BuildContext context, Paper paper) {
    return Card(
      color: Colors.white.withOpacity(0.85),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(
              paper.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${paper.subject} • ${paper.year}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            if (paper.description != null) ...[
              Text(
                paper.description!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
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
            Row(
              children: [
                const CircleAvatar(
                    radius: 12,
                    child: Text('U', style: TextStyle(fontSize: 10))),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(paper.uploaderName,
                        style: Theme.of(context).textTheme.bodySmall)),
                const Icon(Icons.download, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${paper.downloadCount}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
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

// ========== ADMIN SCREEN ==========
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

// ========== MAIN APP ==========
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaperLink',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return appState.isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  void changeIndex(int newIndex) {
    if (mounted) {
      setState(() {
        currentIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isAdmin = appState.currentUser?.isAdmin == true;

        final screens = [
          const DashboardScreen(),
          const UploadScreen(),
          const LibraryScreen(),
          if (isAdmin) const AdminScreen(),
        ];

        return Stack(
          children: [
            // Background Image with Dark Overlay
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg1.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Dark overlay for better readability
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
            // App Content
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text('PaperLink'),
                backgroundColor: Colors.blue.withOpacity(0.8),
                foregroundColor: Colors.white,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(
                        appState.isOffline ? Icons.offline_bolt : Icons.cloud),
                    onPressed: () => appState.toggleOfflineMode(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      appState.logout();
                    },
                  ),
                ],
              ),
              body: currentIndex < screens.length
                  ? screens[currentIndex]
                  : screens[0],
              bottomNavigationBar: BottomNavigationBar(
                backgroundColor: Colors.white.withOpacity(0.9),
                currentIndex: currentIndex.clamp(0, screens.length - 1),
                onTap: (index) => setState(() => currentIndex = index),
                items: [
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard), label: 'Dashboard'),
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.upload), label: 'Upload'),
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.library_books), label: 'Library'),
                  if (isAdmin)
                    const BottomNavigationBarItem(
                        icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
                ],
                type: BottomNavigationBarType.fixed,
              ),
            ),
          ],
        );
      },
    );
  }
}
