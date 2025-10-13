class User {
  final int? id; // nullable pour insertion automatique
  final String username;
  final String email;
  final String password;
  final String dateNaissance;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.dateNaissance,
  });

  /// Convertir en Map pour SQLite
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'username': username,
      'email': email,
      'password': password,
      'dateNaissance': dateNaissance,
    };
    if (id != null) map['id'] = id; // int pour SQLite
    return map;
  }

  /// Créer un User à partir d’un Map (SQLite)
  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'] != null ? map['id'] as int : null,
    username: map['username'] as String,
    email: map['email'] as String,
    password: map['password'] as String,
    dateNaissance: map['dateNaissance'] as String,
  );

  /// Retourne l'id sous forme de String pour affichage
  String get idAsString => id?.toString() ?? '';
}
