import 'package:flutter/material.dart';
import '../db/user_dao.dart';
import '../models/user.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final UserDao userDao = UserDao.instance; 
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final data = await userDao.getAllUsers();
    setState(() => users = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Utilisateurs')),
      body: users.isEmpty
          ? const Center(child: Text('Aucun utilisateur'))
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final u = users[index];
          return ListTile(
            title: Text(u.username),
            subtitle: Text(u.email),
            trailing: Text(u.idAsString),
          );
        },
      ),
    );
  }
}
