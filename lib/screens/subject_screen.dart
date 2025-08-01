import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../providers/quiz_provider.dart'; // Added import for QuizProvider
import 'add_question_screen.dart';
import 'question_bank_screen.dart';
import 'quiz_screen.dart';
import 'mistakes_screen.dart';
import 'leaderboard_screen.dart';

class SubjectScreen extends StatelessWidget {
  final Subject subject;

  const SubjectScreen({super.key, required this.subject});

  // New method for username prompt
  void _promptUsername(BuildContext context, VoidCallback onSuccess) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel: Close dialog without action
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<QuizProvider>(context, listen: false).setUsername(controller.text);
                Navigator.pop(context);
                onSuccess(); // Proceed to quiz after saving
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildButton(
              context,
              icon: Icons.quiz,
              label: 'Start Quiz',
              onPressed: () {
                final provider = Provider.of<QuizProvider>(context, listen: false);
                if (provider.currentUsername == null) {
                  _promptUsername(context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(subject: subject),
                      ),
                    );
                  });
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(subject: subject),
                    ),
                  );
                }
              },
            ),
            _buildButton(
              context,
              icon: Icons.add_circle,
              label: 'Add Question',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddQuestionScreen(subject: subject),
                ),
              ),
            ),
            _buildButton(
              context,
              icon: Icons.library_books,
              label: 'Question Bank',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionBankScreen(subject: subject),
                ),
              ),
            ),
            _buildButton(
              context,
              icon: Icons.error,
              label: 'Mistakes',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MistakesScreen(subject: subject),
                ),
              ),
            ),
            _buildButton(
              context,
              icon: Icons.leaderboard,
              label: 'Leaderboard',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaderboardScreen(subjectId: subject.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 16),
          // Text(label, style: Theme.of(context).textTheme.titleLarge),
          FittedBox(  // Add this wrapper
            fit: BoxFit.scaleDown,
            child: Text(label, style: Theme.of(context).textTheme.titleLarge),
          ),
        ],
      ),
    );
  }
}