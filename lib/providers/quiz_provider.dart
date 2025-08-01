import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class QuizProvider with ChangeNotifier {
  List<Subject> get subjects => StorageService.subjects.values.toList();
  List<Question> get questions => StorageService.questions.values.toList();
  
  void addSubject(Subject subject) {
    StorageService.subjects.put(subject.id, subject);
    notifyListeners();
  }

  void addQuestion(Question question) {
    StorageService.questions.put(question.id, question);
    notifyListeners();
  }

  void importQuestions(List<Question> newQuestions) {
    for (var question in newQuestions) {
      StorageService.questions.put(question.id, question);
    }
    notifyListeners();
  }

  List<QuizResult> getMistakes(String subjectId, {String? username}) {
    return StorageService.results.values.where((result) {
      final question = StorageService.questions.get(result.questionId);
      final matchesSubject = question?.subjectId == subjectId;
      final matchesUser = username == null || result.username == username;
      return matchesSubject && !result.isCorrect && matchesUser;
    }).toList();
  }
  // void recordResult(QuizResult result) {
  //   StorageService.results.put(result.questionId, result);
  // }

  // List<QuizResult> getMistakes(String subjectId) {
  //   return StorageService.results.values
  //       .where((result) {
  //         final question = StorageService.questions.get(result.questionId);
  //         return question?.subjectId == subjectId;
  //       })
  //       .toList();
  // }

  List<Question> getQuestionsForSubject(String subjectId) {
    return questions.where((q) => q.subjectId == subjectId).toList();
  }

  // Add these methods to QuizProvider class
  void deleteQuestion(String questionId) {
    StorageService.questions.delete(questionId);
    
    // Also delete associated results
    if (StorageService.results.containsKey(questionId)) {
      StorageService.results.delete(questionId);
    }
    
    notifyListeners();
  }

  void deleteQuestions(List<String> questionIds) {
    for (final id in questionIds) {
      StorageService.questions.delete(id);
      
      // Delete associated results
      if (StorageService.results.containsKey(id)) {
        StorageService.results.delete(id);
      }
    }
    
    notifyListeners();
  }

  String? _currentUsername;

  String? get currentUsername => _currentUsername;

  void setUsername(String username) {
    _currentUsername = username;
    notifyListeners();
  }

  String? _currentAttemptId;

  // Modified recordResult to include username
  void recordResult(QuizResult result) {
    if (_currentUsername == null) {
      throw Exception('Username must be set before recording results');
    }
    if (_currentAttemptId == null) {
      throw Exception('Attempt ID must be set before recording results');
    }

    final updatedResult = QuizResult(
      questionId: result.questionId,
      selectedIndex: result.selectedIndex,
      isCorrect: result.isCorrect,
      username: _currentUsername!,
      attemptId: _currentAttemptId!,
      timestamp: result.timestamp,
    );
    final uniqueKey = '${result.questionId}-${result.timestamp.millisecondsSinceEpoch}-${_currentUsername}-${_currentAttemptId}';  // Include username in key for uniqueness
    StorageService.results.put(uniqueKey, updatedResult);
  }

  void startNewAttempt() {
    _currentAttemptId = const Uuid().v4();
  }

  // New method for leaderboard: Get ranked users by total correct answers (overall or per subject)
  List<Map<String, dynamic>> getLeaderboard({String? subjectId}) {
    final userScores = <String, int>{};
    for (var result in StorageService.results.values) {
      final question = StorageService.questions.get(result.questionId);
      if (subjectId == null || question?.subjectId == subjectId) {
        // Initialize or update score: start at 0 if absent, increment only if correct
        userScores.update(
          result.username,
          (value) => result.isCorrect ? value + 1 : value,
          ifAbsent: () => result.isCorrect ? 1 : 0,
        );
      }
    }
    // Sort by score descending
    final sorted = userScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => {'username': e.key, 'score': e.value}).toList();
  }

  void clearResults() {
    StorageService.results.clear();
    notifyListeners();
  }
}