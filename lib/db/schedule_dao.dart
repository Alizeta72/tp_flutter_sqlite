import '../models/schedule.dart';

class ScheduleDao {
  final List<Schedule> _schedules = [];

  // Singleton
  ScheduleDao._privateConstructor();
  static final ScheduleDao instance = ScheduleDao._privateConstructor();

  Future<void> insertSchedule(Schedule schedule) async {
    final newSchedule = Schedule(
      id: _schedules.isEmpty ? 1 : (_schedules.last.id ?? 0) + 1,
      courseId: schedule.courseId,
      date: schedule.date,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      room: schedule.room,
    );
    _schedules.add(newSchedule);
  }

  Future<void> updateSchedule(Schedule schedule) async {
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) _schedules[index] = schedule;
  }

  Future<void> deleteSchedule(int id) async {
    _schedules.removeWhere((s) => s.id == id);
  }

  Future<List<Schedule>> getAllSchedules() async => _schedules;

  Future<Schedule?> getScheduleById(int id) async {
    try {
      return _schedules.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
