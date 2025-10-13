import '../models/user.dart';

class UserDao {
  final List<User> _users = [];

  // Singleton
  UserDao._privateConstructor();
  static final UserDao instance = UserDao._privateConstructor();

  /// Ajoute un utilisateur
  Future<void> insertUser(User user) async {
    final newUser = User(
      id: _users.isEmpty ? 1 : (_users.last.id ?? 0) + 1,
      username: user.username,
      email: user.email,
      password: user.password,
      dateNaissance: user.dateNaissance,
    );
    _users.add(newUser);
  }

  /// Retourne un User? ou null
  Future<User?> getUserByEmailAndPassword(String email, String password) async {
    try {
      return _users.firstWhere(
            (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
      );
    } catch (e) {
      return null; // si pas trouvé
    }
  }

  /// Retourne un User? ou null
  Future<User?> getUserByEmail(String email) async {
    try {
      return _users.firstWhere(
            (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null; // si pas trouvé
    }
  }

  /// Tous les utilisateurs
  Future<List<User>> getAllUsers() async => _users;
}
