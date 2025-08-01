import 'package:hive/hive.dart';

part 'question.g.dart';

@HiveType(typeId: 1)
class Question {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final List<String> options;

  @HiveField(4)
  final int correctIndex;

  Question({
    required this.id,
    required this.subjectId,
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}