import 'package:csv/csv.dart';
import 'package:quiz_app/models/question.dart';
import 'package:uuid/uuid.dart';

class CsvService {
  static const fieldDelimiter = ',';

  static Future<List<Question>> parseQuestionsFromCsv(String csvString, String subjectId) async {
    try {
      // Normalize line endings to \n for consistency
      csvString = csvString.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      if (!csvString.endsWith('\n')) {
        csvString += '\n'; // Ensure last row ends properly
      }

      final csvData = const CsvToListConverter(
        fieldDelimiter: fieldDelimiter,
        eol: '\n', // Explicitly set EOL
        shouldParseNumbers: false,
        allowInvalid: true, // Changed to true to skip invalid rows without throwing
      ).convert(csvString);

      if (csvData.isEmpty) return [];

      final questions = <Question>[];
      final uuid = Uuid();

      // Skip header row if exists
      final startIndex = csvData[0][0].toString().toLowerCase().contains('question') ? 1 : 0;

      for (var i = startIndex; i < csvData.length; i++) {
        try {
          final row = csvData[i];
          if (row.length < 6) continue;

          final questionText = row[0].toString().trim();
          if (questionText.isEmpty) continue;

          final options = [
            row[1].toString().trim(),
            row[2].toString().trim(),
            row[3].toString().trim(),
            row[4].toString().trim(),
          ];

          if (options.any((opt) => opt.isEmpty)) continue;

          final correctAnswer = row[5].toString().trim();
          final correctIndex = options.indexWhere((opt) => opt == correctAnswer);

          if (correctIndex == -1) continue;

          questions.add(Question(
            id: uuid.v4(),
            subjectId: subjectId,
            text: questionText,
            options: options,
            correctIndex: correctIndex,
          ));
        } catch (e) {
          print('Error parsing row $i: $e');
          continue;
        }
      }
      return questions;
    } catch (e) {
      print('CSV parsing error: $e');
      return []; // Return empty list on failure to avoid blocking
    }
  }

  static String exportQuestionsToCsv(List<Question> questions) {
    final csvData = [
      ['Question', 'Option1', 'Option2', 'Option3', 'Option4', 'CorrectAnswer']
    ];
    
    for (var question in questions) {
      csvData.add([
        question.text,
        ...question.options,
        question.options[question.correctIndex],
      ]);
    }
    
    return const ListToCsvConverter(
      fieldDelimiter: fieldDelimiter,
    ).convert(csvData);
  }
}