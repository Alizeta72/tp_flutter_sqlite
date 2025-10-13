import 'package:flutter/material.dart';
import '../db/teacher_dao.dart';
import '../models/teacher.dart';

class TeacherDetailsPage extends StatefulWidget {
  final Teacher teacher;
  const TeacherDetailsPage({super.key, required this.teacher});

  @override
  _TeacherDetailsPageState createState() => _TeacherDetailsPageState();
}

class _TeacherDetailsPageState extends State<TeacherDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  // ← Utiliser le singleton
  final TeacherDao _teacherDao = TeacherDao.instance;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.teacher.firstName);
    _lastNameController = TextEditingController(text: widget.teacher.lastName);
    _emailController = TextEditingController(text: widget.teacher.email);
    _phoneController = TextEditingController(text: widget.teacher.phone);
  }

  void updateTeacher() async {
    if (_formKey.currentState!.validate()) {
      final updatedTeacher = Teacher(
        id: widget.teacher.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      await _teacherDao.updateTeacher(updatedTeacher);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enseignant mis à jour')),
      );
      Navigator.pop(context, updatedTeacher);
    }
  }

  void deleteTeacher() async {
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
      await _teacherDao.deleteTeacher(widget.teacher.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enseignant supprimé')),
      );
      Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'enseignant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteTeacher,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Entrez le prénom' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Entrez le nom' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Entrez l\'email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Entrez le téléphone' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: updateTeacher,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Mettre à jour'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
