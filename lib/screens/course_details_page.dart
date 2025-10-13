import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/teacher.dart';
import '../db/teacher_dao.dart';
import '../db/course_dao.dart';

class CourseDetailsPage extends StatefulWidget {
  final Course course;
  const CourseDetailsPage({super.key, required this.course});

  @override
  _CourseDetailsPageState createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  Teacher? teacher;
  // Utiliser les singletons
  final TeacherDao teacherDao = TeacherDao.instance;
  final CourseDao courseDao = CourseDao.instance;

  @override
  void initState() {
    super.initState();
    loadTeacher(widget.course.teacherId);
  }

  Future<void> loadTeacher(int teacherId) async {
    final t = await teacherDao.getTeacherById(teacherId);
    setState(() => teacher = t);
  }

  Future<void> deleteCourse() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce cours ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      await courseDao.deleteCourse(widget.course.id!);
      Navigator.pop(context); // Retour vers la liste
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du cours'),
        actions: [IconButton(icon: const Icon(Icons.delete), onPressed: deleteCourse)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom: ${widget.course.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Description: ${widget.course.description}'),
            const SizedBox(height: 10),
            Text('Enseignant: ${teacher != null ? "${teacher!.firstName} ${teacher!.lastName}" : "Chargement..."}'),
          ],
        ),
      ),
    );
  }
}
