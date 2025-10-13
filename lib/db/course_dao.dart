import '../models/course.dart';

class CourseDao {
  final List<Course> _courses = [];

  CourseDao._privateConstructor();
  static final CourseDao instance = CourseDao._privateConstructor();

  Future<void> insertCourse(Course course) async {
    final newCourse = Course(
      id: _courses.isEmpty ? 1 : (_courses.last.id ?? 0) + 1,
      name: course.name,
      description: course.description,
      teacherId: course.teacherId,
    );
    _courses.add(newCourse);
  }

  Future<void> updateCourse(Course course) async {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) _courses[index] = course;
  }

  Future<void> deleteCourse(int id) async {
    _courses.removeWhere((c) => c.id == id);
  }

  Future<List<Course>> getAllCourses() async => _courses;

  Future<Course?> getCourseById(int id) async {
    try {
      return _courses.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
