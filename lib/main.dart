import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'models/subject.dart';
import 'models/question.dart';
import 'models/quiz_result.dart';
import 'services/storage_service.dart';
import 'services/csv_service.dart';
import 'providers/quiz_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive with Flutter
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(QuestionAdapter());
  Hive.registerAdapter(QuizResultAdapter());
  
  // Open all boxes
  await StorageService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: Builder(
        builder: (context) {
          // Load default data asynchronously
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await _loadDefaultData(context);
          });
          return const QuizApp();
        },
      ),
    ),
  );
}

Future<void> _loadDefaultData(BuildContext context) async {
  
  final provider = Provider.of<QuizProvider>(context, listen: false);
  final prefs = await SharedPreferences.getInstance();
  
  final bool defaultsLoaded = prefs.getBool('defaults_loaded') ?? false;
  
  try {
    if (!defaultsLoaded || provider.subjects.isEmpty) {
      
      final subject1 = Subject(
        id: const Uuid().v4(),
        name: 'Computer Science',
        colorValue: Colors.blue.value,
      );
      final subject2 = Subject(
        id: const Uuid().v4(),
        name: 'App Development',
        colorValue: Colors.green.value,
      );
      
      provider.addSubject(subject1);
      provider.addSubject(subject2);
      
      final csv1 = await rootBundle.loadString('assets/data/computer_science_mcqs.csv');
      final questions1 = await CsvService.parseQuestionsFromCsv(csv1, subject1.id);
      provider.importQuestions(questions1);
      
      final csv2 = await rootBundle.loadString('assets/data/app_dev_mcq.csv');
      final questions2 = await CsvService.parseQuestionsFromCsv(csv2, subject2.id);
      provider.importQuestions(questions2);
      
      await prefs.setBool('defaults_loaded', true);
    } else {
      print('Skipped default load: flag is true and subjects not empty');
    }
  } catch (e) {
    print('Error loading default data: $e');
  }
}