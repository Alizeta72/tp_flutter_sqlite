import '../models/teacher.dart';

class TeacherDao {
  final List<Teacher> _teachers = [];

  // Singleton
  TeacherDao._privateConstructor();
  static final TeacherDao instance = TeacherDao._privateConstructor();

  Future<void> insertTeacher(Teacher teacher) async {
    final newTeacher = Teacher(
      id: _teachers.isEmpty ? 1 : (_teachers.last.id ?? 0) + 1,
      firstName: teacher.firstName,
      lastName: teacher.lastName,
      email: teacher.email,
      phone: teacher.phone,
    );
    _teachers.add(newTeacher);
  }

  Future<void> updateTeacher(Teacher teacher) async {
    final index = _teachers.indexWhere((t) => t.id == teacher.id);
    if (index != -1) _teachers[index] = teacher;
  }

  Future<void> deleteTeacher(int id) async {
    _teachers.removeWhere((t) => t.id == id);
  }

  Future<List<Teacher>> getAllTeachers() async => _teachers;

  Future<Teacher?> getTeacherById(int id) async {
    try {
      return _teachers.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}
