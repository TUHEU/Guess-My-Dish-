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
