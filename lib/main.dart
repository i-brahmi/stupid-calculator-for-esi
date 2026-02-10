import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Semester Grade Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // List of subjects with their coefficients, sorted by coefficient (descending)
  final List<Map<String, dynamic>> subjects = [
    {'name': 'SFSD', 'coefficient': 5.0},
    {'name': 'Analysis', 'coefficient': 5.0},
    {'name': 'Proba', 'coefficient': 5.0},
    {'name': 'Architecture', 'coefficient': 4.0},
    {'name': 'Electronics', 'coefficient': 4.0},
    {'name': 'Algebra', 'coefficient': 3.0},
    {'name': 'Economy', 'coefficient': 2.0},
    {'name': 'English', 'coefficient': 2.0},
  ];

  // Initialize controllers with default value "0"
  final List<TextEditingController> examControllers = List.generate(
    8,
    (_) => TextEditingController(text: '0'),
  );
  final List<TextEditingController> tdControllers = List.generate(
    8,
    (_) => TextEditingController(text: '0'),
  );
  final List<String> subjectNotes = List.filled(8, 'Note: 0.00 / 20');
  String semesterResult = 'Semester Note: 0.00 / 20';

  void calculateNotes() {
    double totalWeightedGrade = 0.0;
    double totalCoefficient = 0.0;

    bool hasError = false;
    String errorMessage = '';

    for (int i = 0; i < subjects.length; i++) {
      String examText = examControllers[i].text;
      String tdText = tdControllers[i].text;

      // Treat empty field as 0
      double examGrade = double.tryParse(examText) ?? 0.0;
      double tdGrade = double.tryParse(tdText) ?? 0.0;

      // Validate grades
      if (examGrade < 0 || examGrade > 20 || tdGrade < 0 || tdGrade > 20) {
        hasError = true;
        errorMessage =
            'Invalid input for ${subjects[i]['name']}. Grades must be between 0 and 20.';
        setState(() {
          subjectNotes[i] = '';
        });
        break;
      }

      double subjectGrade = (examGrade * 0.6) + (tdGrade * 0.4);
      setState(() {
        subjectNotes[i] = 'Note: ${subjectGrade.toStringAsFixed(2)} / 20';
      });

      double coefficient = subjects[i]['coefficient'];
      totalWeightedGrade += subjectGrade * coefficient;
      totalCoefficient += coefficient;
    }

    setState(() {
      if (hasError) {
        semesterResult = errorMessage;
        for (int i = 0; i < subjectNotes.length; i++) {
          if (subjectNotes[i].isNotEmpty && hasError) {
            subjectNotes[i] = '';
          }
        }
      } else if (totalCoefficient == 0) {
        semesterResult = 'Total coefficient cannot be zero.';
      } else {
        double semesterNote = totalWeightedGrade / totalCoefficient;
        semesterResult =
            'Semester Note: ${semesterNote.toStringAsFixed(2)} / 20';
      }
    });
  }

  void clearFields() {
    for (var controller in examControllers) {
      controller.text = '0';
    }
    for (var controller in tdControllers) {
      controller.text = '0';
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
  void initState() {
    super.initState();
    // Calculate initial notes with default values
    calculateNotes();
  }

  @override
  void dispose() {
    for (var controller in examControllers) {
      controller.dispose();
    }
    for (var controller in tdControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Semester Grade Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Made with ❤️ and Flutter by ILYES',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                '𓃵',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(subjects.length, (index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${subjects[index]['name']} (Coefficient: ${subjects[index]['coefficient']})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: examControllers[index],
                              decoration: const InputDecoration(
                                labelText: 'Exam Grade (60%)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              onChanged: (_) => calculateNotes(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: tdControllers[index],
                              decoration: const InputDecoration(
                                labelText: 'TD Grade (40%)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              onChanged: (_) => calculateNotes(),
                            ),
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
            }),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: clearFields,
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                semesterResult,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
