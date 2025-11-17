import '../models/user.dart';

class AuthService {
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

  User? login(String username, String password, {bool isAdminLogin = false}) {
    if (isAdminLogin) {
      if (password.isEmpty) return null;

      try {
        final user = _users
            .firstWhere((user) => user.username == username && user.isAdmin);
        if (password == 'admin123') {
          return user;
        }
        return null;
      } catch (e) {
        return null;
      }
    } else {
      try {
        return _users
            .firstWhere((user) => user.username == username && !user.isAdmin);
      } catch (e) {
        return null;
      }
    }
  }

  List<User> getStudentUsers() {
    return _users.where((user) => !user.isAdmin).toList();
  }

  User? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }
}
