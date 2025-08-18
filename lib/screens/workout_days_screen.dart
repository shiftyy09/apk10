import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../models/workout_day.dart';
import '../models/exercise.dart';
import 'workout_detail_screen.dart';
import 'bmi_form.dart';

class WorkoutDaysScreen extends StatefulWidget {
  const WorkoutDaysScreen({super.key});
  @override
  State<WorkoutDaysScreen> createState() => _WorkoutDaysScreenState();
}

class _WorkoutDaysScreenState extends State<WorkoutDaysScreen> {
  List<WorkoutDay> workoutDays = [];
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadWorkoutDays();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => userName = prefs.getString('nickname') ?? 'Sportoló');
  }

  Future<void> _loadWorkoutDays() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('workoutDays');
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      setState(() => workoutDays = decoded.map((e) => WorkoutDay.fromJson(e)).toList());
    }
  }

  Future<void> _saveWorkoutDays() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(workoutDays.map((e) => e.toJson()).toList());
    await prefs.setString('workoutDays', encoded);
  }

  void _startNewWorkout() async {
    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Új Edzésnap 🏋️', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(hintText: 'Pl. Mell & Tricepsz'),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Mégse')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) Navigator.pop(context, nameCtrl.text.trim());
            },
            child: const Text('Indítás'),
          ),
        ],
      ),
    );
    if (name == null) return;
    final newDay = WorkoutDay(name: name, date: DateTime.now(), exercises: []);
    setState(() => workoutDays.insert(0, newDay));
    await _saveWorkoutDays();
    Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workoutDay: newDay, onSave: (upd) {
      final idx = workoutDays.indexOf(newDay);
      if (idx >= 0 && idx < workoutDays.length) {
        setState(() => workoutDays[idx] = upd);
        _saveWorkoutDays();
      }
    })));
  }

  void _deleteWorkout(int idx) {
    if (idx < 0 || idx >= workoutDays.length) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Törlés megerősítése'),
        content: Text('Biztos törlöd a "${workoutDays[idx].name}" napot?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Mégse')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                if (idx >= 0 && idx < workoutDays.length) {
                  workoutDays.removeAt(idx);
                  _saveWorkoutDays();
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Törlés'),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) => '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [gradientStart, gradientEnd]),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Helló, $userName! 👋', style: const TextStyle(color: Colors.white, fontSize: 28)),
                    const SizedBox(height: 8),
                    const Text('Készen állsz a mai edzésre?', style: TextStyle(color: Colors.white70)),
                  ]),
                ),
              ),
            ),
          ),
          actions: [
            IconButton(onPressed: _startNewWorkout, icon: const Icon(Icons.add, color: Colors.white))
          ],
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((_, idx) {
            final day = workoutDays[idx];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(day.name),
                subtitle: Text(_fmt(day.date)),
                trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteWorkout(idx)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workoutDay: day, onSave: (upd) {
                    if (idx >= 0 && idx < workoutDays.length) {
                      setState(() => workoutDays[idx] = upd);
                      _saveWorkoutDays();
                    }
                  })));
                },
              ),
            );
          }, childCount: workoutDays.length),
        ),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: _startNewWorkout, child: const Icon(Icons.add)),
    );
  }
}
