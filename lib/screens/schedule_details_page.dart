import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/schedule.dart';
import '../models/teacher.dart';
import '../db/schedule_dao.dart';
import '../db/teacher_dao.dart';

class ScheduleDetailsPage extends StatefulWidget {
  final Course course;
  final bool readOnly;
  final VoidCallback? onUpdated;

  const ScheduleDetailsPage({
    super.key,
    required this.course,
    this.readOnly = false,
    this.onUpdated,
  });

  @override
  _ScheduleDetailsPageState createState() => _ScheduleDetailsPageState();
}

class _ScheduleDetailsPageState extends State<ScheduleDetailsPage> {
  final ScheduleDao _scheduleDao = ScheduleDao.instance;
  final TeacherDao _teacherDao = TeacherDao.instance;

  List<Schedule> _schedules = [];
  List<Schedule> _filteredSchedules = [];
  Teacher? _teacher;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allSchedules = await _scheduleDao.getAllSchedules();
    if (!mounted) return;

    _teacher = await _teacherDao.getTeacherById(widget.course.teacherId);

    setState(() {
      _schedules = allSchedules
          .where((s) => s.courseId == widget.course.id)
          .toList();
      _schedules.sort((a, b) {
        final cmp = a.date.compareTo(b.date);
        if (cmp != 0) return cmp;
        final aMin = a.startTime.hour * 60 + a.startTime.minute;
        final bMin = b.startTime.hour * 60 + b.startTime.minute;
        return aMin.compareTo(bMin);
      });
      _applySearch();
    });
  }

  void _applySearch() {
    if (_searchText.isEmpty) {
      _filteredSchedules = List.from(_schedules);
    } else {
      final query = _searchText.toLowerCase();
      _filteredSchedules = _schedules.where((s) {
        final dateStr = '${s.date.day.toString().padLeft(2, '0')}-'
            '${s.date.month.toString().padLeft(2, '0')}-'
            '${s.date.year}';
        final roomStr = s.room.toLowerCase();
        return dateStr.contains(query) || roomStr.contains(query);
      }).toList();
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  double _calculateTotalHours() {
    double total = 0;
    for (var s in _schedules) {
      final start = s.startTime.hour + s.startTime.minute / 60.0;
      final end = s.endTime.hour + s.endTime.minute / 60.0;
      total += (end - start);
    }
    return total;
  }

  Future<void> _showScheduleDialog({Schedule? schedule}) async {
    DateTime selectedDate = schedule?.date ?? DateTime.now();
    TimeOfDay selectedStart =
        schedule?.startTime ?? const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay selectedEnd =
        schedule?.endTime ?? const TimeOfDay(hour: 10, minute: 0);

    await showDialog(
      context: context,
      builder: (context) {
        final roomController = TextEditingController(text: schedule?.room ?? '');
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: Text(schedule == null ? 'Ajouter un horaire' : 'Modifier l\'horaire'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Date'),
                    controller: TextEditingController(
                        text:
                        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setStateDialog(() => selectedDate = picked);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Heure début'),
                    controller: TextEditingController(text: selectedStart.format(context)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedStart,
                      );
                      if (picked != null) setStateDialog(() => selectedStart = picked);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Heure fin'),
                    controller: TextEditingController(text: selectedEnd.format(context)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedEnd,
                      );
                      if (picked != null) setStateDialog(() => selectedEnd = picked);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: roomController,
                    decoration: const InputDecoration(labelText: 'Salle'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler')),
              ElevatedButton(
                onPressed: () async {
                  if (roomController.text.trim().isEmpty) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Indique la salle.')),
                    );
                    return;
                  }
                  final newSchedule = Schedule(
                    id: schedule?.id,
                    courseId: widget.course.id!,
                    date: selectedDate,
                    startTime: selectedStart,
                    endTime: selectedEnd,
                    room: roomController.text.trim(),
                  );
                  if (schedule == null) {
                    await _scheduleDao.insertSchedule(newSchedule);
                  } else {
                    await _scheduleDao.updateSchedule(newSchedule);
                  }
                  widget.onUpdated?.call();
                  if (!mounted) return;
                  Navigator.pop(context);
                  await _loadData();
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteSchedule(Schedule s) async {
    if (s.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Supprimer l\'horaire du ${_formatDate(s.date)} ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      await _scheduleDao.deleteSchedule(s.id!);
      widget.onUpdated?.call();
      if (!mounted) return;
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Horaires — ${widget.course.name}')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Recherche
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Rechercher par date ou salle',
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

            if (_teacher != null)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enseignant : ${_teacher!.firstName} ${_teacher!.lastName}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text("Téléphone : ${_teacher!.phone}"),
                      const SizedBox(height: 2),
                      Text("Email : ${_teacher!.email}"),
                    ],
                  ),
                ),
              ),

            // Contenu
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                "Contenu :",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Cours : ${widget.course.name}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Description : ${widget.course.description}"),
                  ],
                ),
              ),
            ),

            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                    "Volume horaire : ${_calculateTotalHours().toStringAsFixed(2)} h"),
              ),
            ),

            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Programmation",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_filteredSchedules.isEmpty)
                      const Text('Aucun horaire disponible')
                    else
                      ..._filteredSchedules.asMap().entries.map((entry) {
                        final s = entry.value;
                        final index = entry.key;
                        final backgroundColor =
                        index % 2 == 0 ? Colors.blueAccent : Colors.white;
                        final textColor =
                        index % 2 == 0 ? Colors.white : Colors.black87;
                        return Container(
                          color: backgroundColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${_formatDate(s.date)} • ${s.startTime.format(context)} - ${s.endTime.format(context)} • Salle : ${s.room}',
                                  style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              if (!widget.readOnly)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                          Icons.edit,
                                          color: index % 2 == 0
                                              ? Colors.white
                                              : Colors.blueAccent),
                                      onPressed: () =>
                                          _showScheduleDialog(schedule: s),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.redAccent),
                                      onPressed: () => _deleteSchedule(s),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.readOnly
          ? null
          : FloatingActionButton(
        onPressed: () => _showScheduleDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
