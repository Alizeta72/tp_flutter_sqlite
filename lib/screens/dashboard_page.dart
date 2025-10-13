import 'package:flutter/material.dart';
import '../db/course_dao.dart';
import '../db/teacher_dao.dart';
import '../db/schedule_dao.dart';
import '../db/user_dao.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalCourses = 0;
  int totalTeachers = 0;
  int totalSchedules = 0;
  int totalUsers = 0;

  final CourseDao courseDao = CourseDao.instance;
  final TeacherDao teacherDao = TeacherDao.instance;
  final ScheduleDao scheduleDao = ScheduleDao.instance;
  final UserDao userDao = UserDao.instance;

  @override
  void initState() {
    super.initState();
    loadCounts();
  }

  Future<void> loadCounts() async {
    final courses = await courseDao.getAllCourses();
    final teachers = await teacherDao.getAllTeachers();
    final schedules = await scheduleDao.getAllSchedules();
    final users = await userDao.getAllUsers();

    setState(() {
      totalCourses = courses.length;
      totalTeachers = teachers.length;
      totalSchedules = schedules.length;
      totalUsers = users.length;
    });
  }

  void logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Widget buildCard(String title, int count, Color color, IconData icon, String route) {
    return InkWell(
      onTap: () async {
        await Navigator.pushNamed(context, route);
        loadCounts();
      },
      child: Card(
        elevation: 4,
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Navigation', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Enseignants'),
              onTap: () async {
                await Navigator.pushNamed(context, '/teachers');
                loadCounts();
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Cours'),
              onTap: () async {
                await Navigator.pushNamed(context, '/courses');
                loadCounts();
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Horaires'),
              onTap: () async {
                await Navigator.pushNamed(context, '/schedule');
                loadCounts();
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Utilisateurs'),
              onTap: () async {
                await Navigator.pushNamed(context, '/users');
                loadCounts();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Se déconnecter'),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

            return GridView.count(
              shrinkWrap: true,
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                buildCard('Cours', totalCourses, Colors.blue, Icons.book, '/courses'),
                buildCard('Enseignants', totalTeachers, Colors.orange, Icons.person, '/teachers'),
                buildCard('Horaires', totalSchedules, Colors.green, Icons.schedule, '/schedule'),
                buildCard('Utilisateurs', totalUsers, Colors.purple, Icons.group, '/users'),
              ],
            );
          },
        ),
      ),
    );
  }
}
