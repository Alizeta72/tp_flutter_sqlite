import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/schedule.dart';
import '../models/teacher.dart';
import '../db/course_dao.dart';
import '../db/teacher_dao.dart';
import '../db/schedule_dao.dart';
import 'schedule_details_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final CourseDao _courseDao = CourseDao.instance;
  final TeacherDao _teacherDao = TeacherDao.instance;
  final ScheduleDao _scheduleDao = ScheduleDao.instance;

  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  List<Teacher> _teachers = [];
  Map<int, List<Schedule>> _courseSchedules = {};
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final courses = await _courseDao.getAllCourses();
    final teachers = await _teacherDao.getAllTeachers();
    final allSchedules = await _scheduleDao.getAllSchedules();

    if (!mounted) return;

    final scheduleMap = <int, List<Schedule>>{};
    for (var s in allSchedules) {
      scheduleMap.putIfAbsent(s.courseId!, () => []).add(s);
    }

    setState(() {
      _courses = courses;
      _teachers = teachers;
      _courseSchedules = scheduleMap;
      _applySearch();
    });
  }

  void _applySearch() {
    final query = _searchText.toLowerCase();

    _filteredCourses = _courses.where((course) {
      final teacher = _teachers.firstWhere(
            (t) => t.id == course.teacherId,
        orElse: () => Teacher(id: 0, firstName: '', lastName: '', email: '', phone: ''),
      );
      final schedules = _courseSchedules[course.id] ?? [];

      bool matchCourse = course.name.toLowerCase().contains(query);
      bool matchTeacher = '${teacher.firstName} ${teacher.lastName}'.toLowerCase().contains(query);
      bool matchSchedule = schedules.any((s) {
        final dateStr =
            '${s.date.day.toString().padLeft(2,'0')}-${s.date.month.toString().padLeft(2,'0')}-${s.date.year}';
        return s.room.toLowerCase().contains(query) || dateStr.contains(query);
      });

      return matchCourse || matchTeacher || matchSchedule;
    }).toList();
  }

  Teacher getTeacherById(int id) {
    return _teachers.firstWhere(
          (t) => t.id == id,
      orElse: () => Teacher(id: 0, firstName: '', lastName: '', email: '', phone: ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emploi du temps')),
      body: _courses.isEmpty
          ? const Center(child: Text('Aucun cours disponible'))
          : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Champ de recherche unique
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Rechercher par cours, enseignant, salle ou date',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                    _applySearch();
                  });
                },
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 Liste des cours filtrés
            if (_filteredCourses.isEmpty)
              const Center(child: Text('Aucun cours trouvé')),
            ..._filteredCourses.map((course) {
              final teacher = getTeacherById(course.teacherId);
              final schedules = _courseSchedules[course.id] ?? [];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cours : ${course.name}",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Enseignant : ${teacher.firstName} ${teacher.lastName}",
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Voir +", style: TextStyle(color: Colors.white)),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ScheduleDetailsPage(
                                    course: course,
                                    onUpdated: _loadData,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (schedules.isEmpty)
                        const Text('Aucun horaire disponible', style: TextStyle(color: Colors.black54))
                      else
                        Column(
                          children: schedules.asMap().entries.map((entry) {
                            final s = entry.value;
                            final i = entry.key;
                            final bgColor = i % 2 == 0 ? Colors.blueAccent : Colors.white;
                            final textColor = i % 2 == 0 ? Colors.white : Colors.black87;
                            return Container(
                              color: bgColor,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${s.date.day.toString().padLeft(2,'0')}-${s.date.month.toString().padLeft(2,'0')}-${s.date.year} • '
                                          '${s.startTime.format(context)} - ${s.endTime.format(context)} • Salle : ${s.room}',
                                      style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
