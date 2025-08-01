import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../models/subject.dart';
import '../providers/quiz_provider.dart';
import '../services/csv_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class QuestionBankScreen extends StatefulWidget {
  final Subject subject;

  const QuestionBankScreen({super.key, required this.subject});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> {
  Set<String> _selectedQuestionIds = {};
  bool _isSelecting = false;

  void _toggleSelection(String questionId) {
    setState(() {
      if (_selectedQuestionIds.contains(questionId)) {
        _selectedQuestionIds.remove(questionId);
      } else {
        _selectedQuestionIds.add(questionId);
      }
      _isSelecting = _selectedQuestionIds.isNotEmpty;
    });
  }

  void _startSelecting() {
    setState(() => _isSelecting = true);
  }

  void _selectAllQuestions(List<Question> questions) {
    setState(() {
      _selectedQuestionIds = questions.map((q) => q.id).toSet();
      _isSelecting = true;
    });
  }

  void _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Questions'),
        content: Text('Delete ${_selectedQuestionIds.length} question(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Provider.of<QuizProvider>(context, listen: false)
          .deleteQuestions(_selectedQuestionIds.toList());
      setState(() {
        _selectedQuestionIds.clear();
        _isSelecting = false;
      });
    }
  }

  Future<void> _exportQuestions() async {
    final questions = Provider.of<QuizProvider>(context, listen: false)
        .getQuestionsForSubject(widget.subject.id);
    
    List<Question> questionsToExport;
    if (_isSelecting && _selectedQuestionIds.isNotEmpty) {
      // Export selected questions
      questionsToExport = questions
          .where((q) => _selectedQuestionIds.contains(q.id))
          .toList();
    } else {
      // Export all questions
      questionsToExport = questions;
    }

    if (questionsToExport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No questions to export')),
      );
      return;
    }

    try {
      final csvString = CsvService.exportQuestionsToCsv(questionsToExport);
      await Clipboard.setData(ClipboardData(text: csvString));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV copied to clipboard')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _shareSelectedQuestions(List<Question> questions) async {
    if (_selectedQuestionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No questions selected to share')),
      );
      return;
    }
    final selectedQuestions = questions.where((q) => _selectedQuestionIds.contains(q.id)).toList();
    if (selectedQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No questions selected to share')),
      );
      return;
    }
    try {
      final csvString = CsvService.exportQuestionsToCsv(selectedQuestions);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/questions.csv');
      await file.writeAsString(csvString);
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share failed:  [${e.toString()}]')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = context.watch<QuizProvider>()
        .getQuestionsForSubject(widget.subject.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('Question Bank - ${widget.subject.name}'),
        actions: [
          if (questions.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.import_export),
              onPressed: _exportQuestions,
              tooltip: 'Export Questions',
            ),
            if (!_isSelecting)
              IconButton(
                icon: const Icon(Icons.select_all),
                onPressed: _startSelecting,
                tooltip: 'Select Questions',
              ),
          ],
        ],
      ),
      body: questions.isEmpty
          ? const Center(child: Text('No questions available'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      final isSelected = _selectedQuestionIds.contains(question.id);

                      return ListTile(
                        title: Text(question.text),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...question.options.asMap().entries.map((entry) {
                              final i = entry.key;
                              final option = entry.value;
                              return Text(
                                '${i + 1}. $option',
                                style: TextStyle(
                                  color: i == question.correctIndex
                                      ? Colors.green
                                      : null,
                                  fontWeight: i == question.correctIndex
                                      ? FontWeight.bold
                                      : null,
                                ),
                              );
                            }),
                          ],
                        ),
                        leading: _isSelecting
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (_) => _toggleSelection(question.id),
                              )
                            : CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                        onTap: () {
                          if (_isSelecting) {
                            _toggleSelection(question.id);
                          }
                        },
                      );
                    },
                  ),
                ),
                if (_isSelecting)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: Theme.of(context).primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '${_selectedQuestionIds.length} Selected',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.select_all, color: Colors.white),
                          onPressed: () => _selectAllQuestions(questions),
                          tooltip: 'Select All',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: _deleteSelected,
                          tooltip: 'Delete Selected',
                        ),
                        IconButton(
                          icon: const Icon(Icons.import_export, color: Colors.white),
                          onPressed: _exportQuestions,
                          tooltip: 'Export Selected',
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () => _shareSelectedQuestions(questions),
                          tooltip: 'Share Selected',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() {
                            _selectedQuestionIds.clear();
                            _isSelecting = false;
                          }),
                          tooltip: 'Cancel',
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}