import 'package:hive/hive.dart';
import '../models/subject.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';

class StorageService {
  static const String subjectsBox = 'subjects';
  static const String questionsBox = 'questions';
  static const String resultsBox = 'quiz_results';

  static Future<void> init() async {
    // Open all boxes with compaction
    await Future.wait([
      Hive.openBox<Subject>(subjectsBox),
      Hive.openBox<Question>(questionsBox),
      Hive.openBox<QuizResult>(resultsBox),
    ]);
  }

  static Box<Subject> get subjects => Hive.box<Subject>(subjectsBox);
  static Box<Question> get questions => Hive.box<Question>(questionsBox);
  static Box<QuizResult> get results => Hive.box<QuizResult>(resultsBox);
}