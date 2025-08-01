import 'package:hive/hive.dart';

part 'quiz_result.g.dart';

@HiveType(typeId: 2)
class QuizResult {
  @HiveField(0)
  final String questionId;

  @HiveField(1)
  final int selectedIndex;
  
  @HiveField(2)
  final bool isCorrect;
  
  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String username;

  @HiveField(5)
  final String attemptId;

  QuizResult({
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
    required this.username,
    required this.attemptId, // Make it required
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}