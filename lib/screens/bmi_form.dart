import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import '../widgets/glass_card.dart';
import 'workout_days_screen.dart';

class BmiForm extends StatefulWidget {
  const BmiForm({super.key});

  @override
  State<BmiForm> createState() => _BmiFormState();
}

class _BmiFormState extends State<BmiForm> {
  final _nicknameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedLevel = 'Kezdő';
  final List<String> _levels = const ['Kezdő', 'Haladó', 'Profi'];
  double? _bmi;
  String _motivation = '';
  bool _showResult = false;
  double? _recommendedProtein;

  @override
  void initState() {
    super.initState();
    _loadBmiData();
  }

  Future<void> _loadBmiData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nicknameController.text = prefs.getString('nickname') ?? '';
      _weightController.text = prefs.getString('weight') ?? '';
      _heightController.text = prefs.getString('height') ?? '';
      _selectedLevel = prefs.getString('level') ?? 'Kezdő';
      final savedBmi = prefs.getDouble('bmi');
      final savedMotivation = prefs.getString('motivation');
      final savedProtein = prefs.getDouble('protein');
      if (savedBmi != null && savedMotivation != null) {
        _bmi = savedBmi;
        _motivation = savedMotivation;
        _showResult = true;
      }
      if (savedProtein != null) {
        _recommendedProtein = savedProtein;
      }
    });
  }

  Future<void> _saveBmiData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', _nicknameController.text);
    await prefs.setString('weight', _weightController.text);
    await prefs.setString('height', _heightController.text);
    await prefs.setString('level', _selectedLevel);
    if (_bmi != null) await prefs.setDouble('bmi', _bmi!);
    await prefs.setString('motivation', _motivation);
    if (_recommendedProtein != null) await prefs.setDouble('protein', _recommendedProtein!);
  }

  void _calculateBMI() {
    if (_weightController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _nicknameController.text.isEmpty) {
      setState(() => _showResult = false);
      _showSnackBar('Adj meg becenevet, testsúlyt és magasságot! 📝');
      return;
    }

    final weight = double.tryParse(_weightController.text);
    final heightCm = double.tryParse(_heightController.text);
    if (weight == null || heightCm == null || weight <= 0 || heightCm <= 0) {
      _showSnackBar('Kérlek, adj érvényes számokat! 🔢');
      return;
    }

    final heightM = heightCm / 100;
    final bmi = weight / (heightM * heightM);
    String motivation;
    switch (_selectedLevel) {
      case 'Kezdő':
        motivation = "${_nicknameController.text}, minden nagy út egy lépéssel kezdődik! 🌟\nNe izgulj, lassan haladj, és élvezd a folyamatot.";
        break;
      case 'Haladó':
        motivation = "${_nicknameController.text}, szuper munka eddig! 💪\nMost jön az igazi kihívás - lépj ki a komfortzónádból!";
        break;
      case 'Profi':
        motivation = "${_nicknameController.text}, tisztelet! 🚀\nTe már tudod a titkot - következetesség és kitartás.";
        break;
      default:
        motivation = "${_nicknameController.text}, szuper vagy! 🔥";
    }

    final protein = double.parse((weight * 1.8).toStringAsFixed(1));
    setState(() {
      _bmi = double.parse(bmi.toStringAsFixed(1));
      _motivation = motivation;
      _recommendedProtein = protein;
      _showResult = true;
    });
    _saveBmiData();
  }

  void _goToWorkoutDays() {
    if (_showResult) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WorkoutDaysScreen()),
      );
    } else {
      _showSnackBar('Előbb számold ki a BMI-t! 📊');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                Colors.white54,
                Colors.white24,
              ],
            ),
            border: Border.all(color: Colors.white30),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Color(0xff212327), fontSize: 16, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Milyen szinten vagy?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: _levels.map((level) {
            final isSelected = _selectedLevel == level;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedLevel = level),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: isSelected
                          ? const [accentPink, primaryPurple]
                          : [Colors.white54, Colors.white24],
                    ),
                    border: Border.all(
                      color: isSelected ? Colors.white54 : Colors.white30,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: accentPink.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                        : null,
                  ),
                  child: Text(
                    level,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'BMI: ',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$_bmi',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _motivation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          if (_recommendedProtein != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
              ),
              child: Text(
                'Ajánlott napi fehérjebevitel: $_recommendedProtein g 🥗',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [accentPink, primaryPurple],
              ),
              boxShadow: [
                BoxShadow(
                  color: accentPink.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _goToWorkoutDays,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Kezdjük az edzést! 🚀',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: Navigator.canPop(context)
          ? AppBar(
        title: const Text('Profil beállítások'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!Navigator.canPop(context)) ...[
                const Center(
                  child: Column(
                    children: [
                      Text(
                        'GYMFLOW',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Kezdjünk az alapokkal',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 0),
              ],
              const GlassCard(
                child: SizedBox.shrink(),
              ),
              GlassCard(
                child: _buildInputField('Becenév', _nicknameController, 'Pl. Fitness Rajongó'),
              ),
              GlassCard(
                child: _buildInputField(
                  'Testsúly (kg)',
                  _weightController,
                  '70',
                  keyboardType: TextInputType.number,
                ),
              ),
              GlassCard(
                child: _buildInputField(
                  'Magasság (cm)',
                  _heightController,
                  '175',
                  keyboardType: TextInputType.number,
                ),
              ),
              GlassCard(
                child: _buildLevelSelector(),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.white70],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _calculateBMI,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'BMI Számítás 📊',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: primaryPurple,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (_showResult) _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }
}
