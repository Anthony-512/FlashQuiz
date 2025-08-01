import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../providers/quiz_provider.dart';
import 'package:uuid/uuid.dart';

class QuizScreen extends StatefulWidget {
  final Subject subject;

  const QuizScreen({super.key, required this.subject});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Question> _questions;
  int _currentIndex = 0;
  int? _selectedOption;
  int _correctCount = 0;
  late DateTime _startTime;
  bool _isFinished = false;
  final List<QuizResult> _results = [];
  late List<List<String>> _shuffledOptions;
  late String _attemptId;
  
  // State for answer feedback
  bool _answerSubmitted = false;
  bool _isCorrect = false;
  int? _correctShuffledIndex;
  int? _selectedShuffledIndex;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
    _startTime = DateTime.now();
    _attemptId = const Uuid().v4();
    context.read<QuizProvider>().startNewAttempt();
  }

  void _initializeQuiz() {
    final provider = context.read<QuizProvider>();
    _questions = provider.getQuestionsForSubject(widget.subject.id);
    
    if (_questions.isNotEmpty) {
      _questions.shuffle();
      
      // Pre-shuffle options for each question
      _shuffledOptions = _questions.map((question) {
        final options = List.of(question.options);
        options.shuffle();
        return options;
      }).toList();
    }
  }

  void _submitAnswer() {
    if (_selectedOption == null) return;

    final question = _questions[_currentIndex];
    final originalOptions = question.options;
    final options = _shuffledOptions[_currentIndex];
    
    // Get selected option text
    final selectedOptionText = options[_selectedOption!];
    
    // Find original index of selected option
    final selectedOriginalIndex = originalOptions.indexOf(selectedOptionText);
    
    // Get correct option text and its shuffled index
    final correctOptionText = originalOptions[question.correctIndex];
    final isCorrect = selectedOptionText == correctOptionText;
    
    // Find the correct option's position in the shuffled list
    final correctShuffledIndex = options.indexOf(correctOptionText);

    if (isCorrect) _correctCount++;

    _results.add(QuizResult(
      questionId: question.id,
      selectedIndex: selectedOriginalIndex,
      isCorrect: isCorrect,
      username: context.read<QuizProvider>().currentUsername ?? 'Guest',  // Added required username parameter with fallback
      attemptId: _attemptId,
    ));

    setState(() {
      _answerSubmitted = true;
      _isCorrect = isCorrect;
      _selectedShuffledIndex = _selectedOption;
      _correctShuffledIndex = correctShuffledIndex;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answerSubmitted = false;
        _isCorrect = false;
        _correctShuffledIndex = null;
        _selectedShuffledIndex = null;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    final duration = DateTime.now().difference(_startTime);
    final provider = context.read<QuizProvider>();
    
    for (var result in _results) {
      provider.recordResult(result);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Correct Answers: $_correctCount/${_questions.length}'),
            Text('Time: ${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s'),
            Text('Accuracy: ${(_correctCount / _questions.length * 100).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous page
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.subject.name)),
        body: const Center(child: Text('No questions available')),
      );
    }

    final question = _questions[_currentIndex];
    final options = _shuffledOptions[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.subject.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
              ),
              const SizedBox(height: 20),
              Text(
                'Question ${_currentIndex + 1}/${_questions.length}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Text(
                question.text,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 30),
              
              // Existing option buttons code (with FittedBox added for text)
              ...options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                
                Color? bgColor;
                OutlinedBorder? shape;
                Widget? iconWidget;
                if (_answerSubmitted) {
                  if (index == _correctShuffledIndex) {
                    bgColor = Colors.green[200]; // Correct answer
                    shape = RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    );
                    iconWidget = const Icon(Icons.check_circle, color: Colors.green, size: 24);
                  } else if (index == _selectedShuffledIndex && !_isCorrect) {
                    bgColor = Colors.red[200]; // Wrong selection
                  }
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bgColor ?? 
                        (_selectedOption == index ? Colors.blue[200] : null),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: shape,
                    ),
                    onPressed: _answerSubmitted ? null : () => setState(() => _selectedOption = index),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (iconWidget != null) ...[
                          iconWidget,
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              option,
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 20),
              if (_answerSubmitted)
                Text(
                  _isCorrect ? 'Correct!' : 'Incorrect!',
                  style: TextStyle(
                    color: _isCorrect ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _selectedOption == null && !_answerSubmitted 
                  ? null 
                  : _answerSubmitted ? _nextQuestion : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _answerSubmitted
                    ? Colors.blue
                    : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _answerSubmitted ? 'Next Question' : 'Submit Answer',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20), // Extra bottom padding
            ],
          ),
        ),
      ),
    );
  }
}