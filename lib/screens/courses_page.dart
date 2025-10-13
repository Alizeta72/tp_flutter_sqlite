import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/teacher.dart';
import '../db/course_dao.dart';
import '../db/teacher_dao.dart';
import 'course_details_page.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  List<Course> courses = [];
  List<Course> filteredCourses = [];
  List<Teacher> teachers = [];

  final TeacherDao teacherDao = TeacherDao.instance;
  final CourseDao courseDao = CourseDao.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int? _selectedTeacherId;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    final allCourses = await courseDao.getAllCourses();
    final allTeachers = await teacherDao.getAllTeachers();
    setState(() {
      courses = allCourses;
      teachers = allTeachers;
      filteredCourses = List.from(courses);

      if (teachers.isNotEmpty && _selectedTeacherId == null) {
        _selectedTeacherId = teachers.first.id;
      }
    });
  }

  void applySearch(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredCourses = courses.where((c) {
        final teacher = teachers.firstWhere(
              (t) => t.id == c.teacherId,
          orElse: () => Teacher(id: 0, firstName: '', lastName: '', email: '', phone: ''),
        );
        final courseMatch = c.name.toLowerCase().contains(lowerQuery);
        final teacherMatch = '${teacher.firstName} ${teacher.lastName}'.toLowerCase().contains(lowerQuery);
        return courseMatch || teacherMatch;
      }).toList();
    });
  }

  void showCourseDialog({Course? course}) {
    if (course != null) {
      _nameController.text = course.name;
      _descriptionController.text = course.description;
      _selectedTeacherId = course.teacherId;
    } else {
      _nameController.clear();
      _descriptionController.clear();
      if (teachers.isNotEmpty) _selectedTeacherId = teachers.first.id;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course == null ? 'Ajouter un cours' : 'Modifier le cours'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom du cours'),
                  validator: (v) => v!.isEmpty ? 'Veuillez entrer le nom du cours' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (v) => v!.isEmpty ? 'Veuillez entrer la description' : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedTeacherId,
                  items: teachers
                      .map((t) => DropdownMenuItem(
                    value: t.id,
                    child: Text('${t.firstName} ${t.lastName}'),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedTeacherId = v),
                  decoration: const InputDecoration(labelText: 'Enseignant'),
                  validator: (v) => v == null ? 'Sélectionnez un enseignant' : null,
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
                final newCourse = Course(
                  id: course?.id,
                  name: _nameController.text.trim(),
                  description: _descriptionController.text.trim(),
                  teacherId: _selectedTeacherId!,
                );
                if (course == null) {
                  await courseDao.insertCourse(newCourse);
                } else {
                  await courseDao.updateCourse(newCourse);
                }
                await loadData();
                Navigator.pop(context);
              }
            },
            child: Text(course == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  void deleteCourse(Course course) async {
    final confirmed = await showDialog<bool>(
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
    if (confirmed == true) {
      await courseDao.deleteCourse(course.id!);
      await loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des cours')),
      body: courses.isEmpty
          ? const Center(child: Text('Aucun cours disponible'))
          : Column(
        children: [
          // Champ de recherche
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Rechercher cours ou enseignant',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: applySearch,
            ),
          ),
          Expanded(
            child: filteredCourses.isEmpty
                ? const Center(child: Text('Aucun cours trouvé'))
                : ListView.builder(
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                final course = filteredCourses[index];
                final teacher = teachers.firstWhere(
                      (t) => t.id == course.teacherId,
                  orElse: () => Teacher(id: 0, firstName: '', lastName: '', email: '', phone: ''),
                );
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(course.name),
                    subtitle: Text('${course.description}\nEnseignant: ${teacher.firstName} ${teacher.lastName}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => showCourseDialog(course: course),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteCourse(course),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CourseDetailsPage(course: course)),
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
        onPressed: () => showCourseDialog(),
      ),
    );
  }
}
