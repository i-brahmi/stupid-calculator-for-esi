import 'package:esicalc1cs/subject.dart';
import 'package:esicalc1cs/subject_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final List<Subject> subjects = const [
    Subject(name: 'BDD', coefficient: 5),
    Subject(name: 'Networks', coefficient: 4),
    Subject(name: 'THL', coefficient: 4),
    Subject(name: 'Anum', coefficient: 4),
    Subject(name: 'System', coefficient: 4),
    Subject(name: 'IGL', coefficient: 4),
    Subject(name: 'RO', coefficient: 3),
    Subject(name: 'English', coefficient: 2),
  ];

  static const double examWeight = 0.6;
  static const double tdWeight = 0.4;
  static const double maxGrade = 20.0;

  late final List<SubjectControllers> controllers;
  late final List<String> subjectNotes;

  String semesterResult = 'Semester Note: 0.00 / 20';

  @override
  void initState() {
    super.initState();
    controllers = List.generate(subjects.length, (_) => SubjectControllers());
    subjectNotes = List.generate(subjects.length, (_) => 'Note: 0.00 / 20');

    calculateNotes();
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void calculateNotes() {
    double totalWeightedGrade = 0;
    double totalCoefficient = 0;

    for (int i = 0; i < subjects.length; i++) {
      final exam = _parseGrade(controllers[i].exam.text);
      final td = _parseGrade(controllers[i].td.text);

      if (!_isValidGrade(exam) || !_isValidGrade(td)) {
        setState(() {
          semesterResult =
              'Invalid input for ${subjects[i].name}. Grades must be between 0 and 20.';
          subjectNotes[i] = '';
        });
        return;
      }

      final subjectGrade = _calculateSubjectGrade(exam, td);
      subjectNotes[i] = 'Note: ${subjectGrade.toStringAsFixed(2)} / 20';

      totalWeightedGrade += subjectGrade * subjects[i].coefficient;
      totalCoefficient += subjects[i].coefficient;
    }

    final semesterNote = totalWeightedGrade / totalCoefficient;

    setState(() {
      semesterResult = 'Semester Note: ${semesterNote.toStringAsFixed(2)} / 20';
    });
  }

  double _calculateSubjectGrade(double exam, double td) {
    return (exam * examWeight) + (td * tdWeight);
  }

  double _parseGrade(String value) {
    return double.tryParse(value) ?? 0;
  }

  bool _isValidGrade(double grade) {
    return grade >= 0 && grade <= maxGrade;
  }

  void clearFields() {
    for (final c in controllers) {
      c.clear();
    }

    setState(() {
      for (int i = 0; i < subjectNotes.length; i++) {
        subjectNotes[i] = 'Note: 0.00 / 20';
      }
      semesterResult = 'Semester Note: 0.00 / 20';
    });

    calculateNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Semester Grade Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Made with ❤️ and Flutter by ILYES',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text('𓃵', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),

            ...List.generate(subjects.length, _buildSubjectCard),

            const SizedBox(height: 20),
            ElevatedButton(onPressed: clearFields, child: const Text('Clear')),
            const SizedBox(height: 30),
            Text(
              semesterResult,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(int index) {
    final subject = subjects[index];
    final subjectControllers = controllers[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${subject.name} (Coefficient: ${subject.coefficient})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildGradeField(
                  controller: subjectControllers.exam,
                  label: 'Exam (60%)',
                ),
                const SizedBox(width: 10),
                _buildGradeField(
                  controller: subjectControllers.td,
                  label: 'TD (40%)',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subjectNotes[index],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeField({
    required TextEditingController controller,
    required String label,
  }) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => calculateNotes(),
      ),
    );
  }
}
