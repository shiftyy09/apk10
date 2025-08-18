import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/workout_day.dart';
import '../models/exercise.dart';
import '../models/set_data.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutDay workoutDay;
  final ValueChanged<WorkoutDay> onSave;

  const WorkoutDetailScreen({super.key, required this.workoutDay, required this.onSave});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late WorkoutDay _currentWorkout;

  @override
  void initState() {
    super.initState();
    _currentWorkout = WorkoutDay(
      name: widget.workoutDay.name,
      date: widget.workoutDay.date,
      exercises: widget.workoutDay.exercises
          .map((e) => Exercise(
        name: e.name,
        tip: e.tip,
        sets: List<SetData>.from(e.sets),
      ))
          .toList(),
    );
  }

  void _addSet(int exerciseIndex, double weight, int reps) {
    setState(() {
      _currentWorkout.exercises[exerciseIndex].sets.add(SetData(weight: weight, reps: reps));
    });
    widget.onSave(_currentWorkout);
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      if (exerciseIndex >= 0 &&
          exerciseIndex < _currentWorkout.exercises.length &&
          setIndex >= 0 &&
          setIndex < _currentWorkout.exercises[exerciseIndex].sets.length) {
        _currentWorkout.exercises[exerciseIndex].sets.removeAt(setIndex);
      }
    });
    widget.onSave(_currentWorkout);
  }

  Future<void> _showAddSetDialog(int exerciseIndex) async {
    final weightController = TextEditingController();
    final repsController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${_currentWorkout.exercises[exerciseIndex].name} - Új sorozat',
          style: const TextStyle(color: darkGray, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Súly (kg)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: primaryPurple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Ismétlés',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: primaryPurple, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Mégse', style: TextStyle(color: Colors.black.withOpacity(0.6))),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(colors: [accentPink, primaryPurple]),
            ),
            child: ElevatedButton(
              onPressed: () {
                final weight = double.tryParse(weightController.text);
                final reps = int.tryParse(repsController.text);
                if (weight != null && weight > 0 && reps != null && reps > 0) {
                  Navigator.pop(context, {'weight': weight, 'reps': reps});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kérlek adj meg érvényes értékeket!'),
                      backgroundColor: primaryPurple,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Mentés', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _currentWorkout.exercises[exerciseIndex].sets.add(SetData(weight: result['weight'], reps: result['reps']));
      });
      widget.onSave(_currentWorkout);
    }
  }

  void _addExercise() {
    final newExerciseNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Új gyakorlat hozzáadása', style: TextStyle(color: darkGray, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: TextField(
            controller: newExerciseNameController,
            decoration: InputDecoration(
              hintText: 'Gyakorlat neve',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: primaryPurple, width: 2),
              ),
            ),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Mégse', style: TextStyle(color: Colors.black.withOpacity(0.6))),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(colors: [accentPink, primaryPurple]),
            ),
            child: ElevatedButton(
              onPressed: () {
                final name = newExerciseNameController.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _currentWorkout.exercises.add(Exercise(name: name, tip: ''));
                  });
                  widget.onSave(_currentWorkout);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Hozzáadás', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _removeExercise(int index) {
    if (index < 0 || index >= _currentWorkout.exercises.length) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Gyakorlat törlése', style: TextStyle(color: darkGray, fontWeight: FontWeight.bold)),
        content: Text('Biztos törlöd a "${_currentWorkout.exercises[index].name}" gyakorlatot?', style: const TextStyle(color: darkGray)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Mégse', style: TextStyle(color: Colors.black.withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (index >= 0 && index < _currentWorkout.exercises.length) {
                  _currentWorkout.exercises.removeAt(index);
                }
              });
              widget.onSave(_currentWorkout);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Törlés', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _saveWorkout() {
    final hasValidExercise = _currentWorkout.exercises.any((e) => e.sets.isNotEmpty);
    if (_currentWorkout.exercises.isEmpty || !hasValidExercise) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adj hozzá legalább egy gyakorlatot, amelynek van mentett sorozata is!'),
          backgroundColor: primaryPurple,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    widget.onSave(_currentWorkout);
    Navigator.pop(context);
  }

  String _formatDate(DateTime dt) => '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [lightGray, Colors.white],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [gradientStart, gradientEnd]),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 36, 20, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _currentWorkout.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(_currentWorkout.date),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.08)]),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.save, color: Colors.white),
                    onPressed: _saveWorkout,
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _currentWorkout.exercises.isEmpty
                  ? SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [gradientStart, gradientEnd]),
                        ),
                        child: const Icon(Icons.add, size: 42, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Nincs még gyakorlat',
                        style: TextStyle(
                          color: Color(0xFF31343A),
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adj hozzá egyet a + gombbal!',
                        style: TextStyle(color: Color(0x992D3748), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _currentWorkout.exercises.length,
                itemBuilder: (context, exIndex) {
                  final exercise = _currentWorkout.exercises[exIndex];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: cardBackground,
                      boxShadow: [
                        BoxShadow(
                          color: primaryPurple.withOpacity(0.08),
                          blurRadius: 13,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.all(20),
                      title: Text(
                        exercise.name,
                        style: const TextStyle(
                          color: darkGray,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: exercise.previousWeight != null
                          ? Text(
                        'Előző súly: ${exercise.previousWeight!.toStringAsFixed(1)} kg',
                        style: const TextStyle(color: primaryPurple, fontWeight: FontWeight.w600),
                      )
                          : null,
                      children: [
                        if (exercise.tip.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: lightPurple.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Tipp: ${exercise.tip}',
                                style: const TextStyle(color: primaryPurple, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        if (exercise.sets.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Nincs még sorozat hozzáadva',
                              style: TextStyle(color: Color(0xFFF5F5F5), fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ...exercise.sets.asMap().entries.map((entry) {
                          final setIndex = entry.key;
                          final set = entry.value;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [gradientStart.withOpacity(0.08), gradientEnd.withOpacity(0.09)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Súly: ${set.weight.toStringAsFixed(1)} kg • Ismétlés: ${set.reps}',
                                    style: const TextStyle(
                                      color: Color(0xFF212327), // Extra sötétszürke
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.redAccent.withOpacity(0.09),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.redAccent, size: 19),
                                    onPressed: () => _removeSet(exIndex, setIndex),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(colors: [lightPurple, primaryPurple]),
                            ),
                            child: TextButton.icon(
                              onPressed: () => _showAddSetDialog(exIndex),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                'Új sorozat hozzáadása',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [accentPink, primaryPurple]),
          boxShadow: [
            BoxShadow(
              color: accentPink.withOpacity(0.35),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: _addExercise,
          child: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
    );
  }
}
