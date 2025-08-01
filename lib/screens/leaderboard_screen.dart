import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../models/subject.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key, this.subjectId});

  final String? subjectId;

  @override
  Widget build(BuildContext context) {
    final leaderboard = Provider.of<QuizProvider>(context).getLeaderboard(subjectId: subjectId);
    
    return Scaffold(
      appBar: AppBar(
        title: Consumer<QuizProvider>(  // Use Consumer to access subjects
          builder: (context, provider, child) {
            if (subjectId == null) {
              return const Text('Overall Leaderboard');
            }
            final subject = provider.subjects.firstWhere(
              (s) => s.id == subjectId,
              orElse: () => Subject(id: '', name: 'Unknown', colorValue: 0),  // Fallback
            );
            return Text('Leaderboard for ${subject.name}');
          },
        ),
        actions: [ // Added clear button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Records'),
                  content: const Text('Are you sure you want to clear all quiz results?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<QuizProvider>(context, listen: false).clearResults();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: leaderboard.isEmpty
          ? const Center(child: Text('No results yet'))
          : ListView.builder(
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                return ListTile(
                  leading: Text('${index + 1}.'),
                  title: Text(entry['username']),
                  trailing: Text('Score: ${entry['score']}'),
                );
              },
            ),
    );
  }
}