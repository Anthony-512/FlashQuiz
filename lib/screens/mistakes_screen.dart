import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../models/subject.dart';
import '../providers/quiz_provider.dart';

class MistakesScreen extends StatelessWidget {
  final Subject subject;

  const MistakesScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final mistakes = quizProvider.getMistakes(
      subject.id, 
      username: quizProvider.currentUsername
    );
    final questions = quizProvider.questions;

    return Scaffold(
      appBar: AppBar(title: Text('Mistakes - ${subject.name}')),
      body: ListView.builder(
        itemCount: mistakes.length,
        itemBuilder: (context, index) {
          final result = mistakes[index];
          final question = questions.firstWhere(
            (q) => q.id == result.questionId,
            orElse: () => Question(
              id: result.questionId,
              subjectId: subject.id,
              text: 'Question not found',
              options: [],
              correctIndex: -1,
            ),
          );

          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...question.options.asMap().entries.map((entry) {
                    final i = entry.key;
                    final option = entry.value;
                    
                    Color color = Colors.black;
                    if (i == question.correctIndex) {
                      color = Colors.green;
                    } else if (i == result.selectedIndex) {
                      color = Colors.red;
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        option,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          decoration: i == result.selectedIndex
                              ? TextDecoration.underline
                              : null,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   final mistakes = context.watch<QuizProvider>().getMistakes(subject.id);
  //   final questions = context.watch<QuizProvider>().questions;

  //   return Scaffold(
  //     appBar: AppBar(title: Text('Mistakes - ${subject.name}')),
  //     body: ListView.builder(
  //       itemCount: mistakes.length,
  //       itemBuilder: (context, index) {
  //         final result = mistakes[index];
  //         final question = questions.firstWhere(
  //           (q) => q.id == result.questionId,
  //           orElse: () => Question(
  //             id: '',
  //             subjectId: '',
  //             text: 'Question not found',
  //             options: [],
  //             correctIndex: 0,
  //           ),
  //         );

  //         return Card(
  //           margin: const EdgeInsets.all(8),
  //           child: Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   question.text,
  //                   style: const TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 10),
  //                 ...question.options.asMap().entries.map((entry) {
  //                   final i = entry.key;
  //                   final option = entry.value;
  //                   Color color = Colors.black;
  //                   if (i == question.correctIndex) {
  //                     color = Colors.green;
  //                   } else if (i == result.selectedIndex) {
  //                     color = Colors.red;
  //                   }
  //                   return Padding(
  //                     padding: const EdgeInsets.symmetric(vertical: 4.0),
  //                     child: Text(
  //                       option,
  //                       style: TextStyle(color: color, fontWeight: FontWeight.bold),
  //                     ),
  //                   );
  //                 }),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
}