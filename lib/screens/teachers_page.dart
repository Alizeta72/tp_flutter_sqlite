import 'package:flutter/material.dart';
import '../db/teacher_dao.dart';
import '../models/teacher.dart';
import 'teacher_details_page.dart';

class TeachersPage extends StatefulWidget {
  const TeachersPage({super.key});

  @override
  _TeachersPageState createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  final TeacherDao teacherDao = TeacherDao.instance;
  List<Teacher> teachers = [];
  List<Teacher> filteredTeachers = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTeachers();
  }

  Future<void> loadTeachers() async {
    final data = await teacherDao.getAllTeachers();
    setState(() {
      teachers = data;
      filteredTeachers = List.from(teachers);
    });
  }

  void applySearch(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredTeachers = teachers.where((t) {
        return t.firstName.toLowerCase().contains(lowerQuery) ||
            t.lastName.toLowerCase().contains(lowerQuery) ||
            t.email.toLowerCase().contains(lowerQuery) ||
            t.phone.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  void showTeacherDialog({Teacher? teacher}) {
    if (teacher != null) {
      _firstNameController.text = teacher.firstName;
      _lastNameController.text = teacher.lastName;
      _emailController.text = teacher.email;
      _phoneController.text = teacher.phone;
    } else {
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(teacher == null ? 'Ajouter un enseignant' : 'Modifier enseignant'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer le prénom' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer le nom' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer l\'email' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer le téléphone' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final newTeacher = Teacher(
                  id: teacher?.id,
                  firstName: _firstNameController.text.trim(),
                  lastName: _lastNameController.text.trim(),
                  email: _emailController.text.trim(),
                  phone: _phoneController.text.trim(),
                );
                if (teacher == null) {
                  await teacherDao.insertTeacher(newTeacher);
                } else {
                  await teacherDao.updateTeacher(newTeacher);
                }
                Navigator.pop(context);
                await loadTeachers();
              }
            },
            child: Text(teacher == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteTeacher(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cet enseignant ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      await teacherDao.deleteTeacher(id);
      await loadTeachers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des enseignants')),
      body: Column(
        children: [
          // 🔹 Champ de recherche
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Rechercher par prénom, nom, email ou téléphone',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: applySearch,
            ),
          ),
          Expanded(
            child: filteredTeachers.isEmpty
                ? const Center(child: Text('Aucun enseignant trouvé'))
                : ListView.builder(
              itemCount: filteredTeachers.length,
              itemBuilder: (context, index) {
                final teacher = filteredTeachers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text('${teacher.firstName} ${teacher.lastName}'),
                    subtitle: Text('${teacher.email} | ${teacher.phone}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => showTeacherDialog(teacher: teacher),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteTeacher(teacher.id!),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherDetailsPage(teacher: teacher),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showTeacherDialog(),
      ),
    );
  }
}
