import 'package:flutter/material.dart';
import '../models/paper.dart';
import '../models/user.dart';
import '../models/enums.dart';
import 'auth_service.dart';

class AppState with ChangeNotifier {
  final List<Paper> _papers = [];
  final List<Paper> _uploadedPapers = [];
  User? _currentUser;
  bool _isOffline = false;
  int _currentTab = 0;
  final AuthService _authService = AuthService();

  List<Paper> get papers =>
      _papers.where((p) => p.status == 'approved').toList();
  List<Paper> get uploadedPapers => _uploadedPapers;
  User? get currentUser => _currentUser;
  bool get isOffline => _isOffline;
  bool get isLoggedIn => _currentUser != null;
  int get currentTab => _currentTab;

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
        filePath: 'assets/sample_papers/math_final_2023.pdf',
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
        filePath: 'assets/sample_papers/biology_notes_2023.pdf',
      ),
    ]);

    _uploadedPapers.addAll([
      Paper(
        id: '3',
        title: 'Chemistry Quiz',
        subject: 'Chemistry',
        level: UniversityLevel.level1,
        year: '2023',
        uploaderId: 'student123',
        uploaderName: 'john_doe',
        contentType: ContentType.quiz,
        status: 'pending',
        fileType: 'PDF',
        uploadDate: DateTime(2024, 1, 20),
        description: 'Weekly chemistry quiz',
        tags: ['quiz', 'organic-chemistry'],
        downloadCount: 0,
        filePath: 'assets/sample_papers/chemistry_quiz.pdf',
      ),
    ]);
  }

  void setCurrentTab(int tabIndex) {
    _currentTab = tabIndex;
    notifyListeners();
  }

  Future<bool> login(String username, String password,
      {bool isAdminLogin = false}) async {
    try {
      final user =
          _authService.login(username, password, isAdminLogin: isAdminLogin);
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

  void quickStudentLogin(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _currentTab = 0;
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
