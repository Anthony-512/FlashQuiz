import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/question.dart';
import '../models/subject.dart';
import '../providers/quiz_provider.dart';
import '../services/csv_service.dart';
import 'dart:io'; // Added for File

class AddQuestionScreen extends StatefulWidget {
  final Subject subject;

  const AddQuestionScreen({super.key, required this.subject});

  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  int? _correctOption;

  void _addQuestion() {
    if (_formKey.currentState!.validate() && _correctOption != null) {
      final question = Question(
        id: const Uuid().v4(),
        subjectId: widget.subject.id,
        text: _questionController.text,
        options: [
          _option1Controller.text,
          _option2Controller.text,
          _option3Controller.text,
          _option4Controller.text,
        ],
        correctIndex: _correctOption!,
      );

      context.read<QuizProvider>().addQuestion(question);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question added')),
      );
      _resetForm();
    }
  }

  Future<void> _importCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null) return;

      final file = result.files.single;
      String? csvString;

      if (file.bytes != null && file.bytes!.isNotEmpty) {
        csvString = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        // Read from file path (works on iOS/macOS)
        final f = File(file.path!);
        csvString = await f.readAsString();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Empty file selected')),
        );
        return;
      }

      final questions = await CsvService.parseQuestionsFromCsv(csvString, widget.subject.id);

      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid questions found in CSV')),
        );
        return;
      }

      context.read<QuizProvider>().importQuestions(questions);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported  {questions.length} questions'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed:  {e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
      print('Import error: $e');
    }
  }

  void _resetForm() {
    _questionController.clear();
    _option1Controller.clear();
    _option2Controller.clear();
    _option3Controller.clear();
    _option4Controller.clear();
    setState(() => _correctOption = null);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Questions - ${widget.subject.name}'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add), text: 'Single'),
              Tab(icon: Icon(Icons.import_export), text: 'Import CSV'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Single Question Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _questionController,
                      decoration: const InputDecoration(labelText: 'Question'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    ...List.generate(4, (index) {
                      final controllers = [
                        _option1Controller,
                        _option2Controller,
                        _option3Controller,
                        _option4Controller,
                      ];
                      return ListTile(
                        leading: Radio<int>(
                          value: index,
                          groupValue: _correctOption,
                          onChanged: (value) => setState(() => _correctOption = value),
                        ),
                        title: TextFormField(
                          controller: controllers[index],
                          decoration: InputDecoration(labelText: 'Option ${index + 1}'),
                          validator: (value) => value!.isEmpty ? 'Required' : null,
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addQuestion,
                      child: const Text('Add Question'),
                    ),
                  ],
                ),
              ),
            ),
            // CSV Import Tab
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Import questions from CSV file',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    const Text('CSV Format:'),
                    const Text('Question, Option1, Option2, Option3, Option4, CorrectIndex'),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _importCsv,
                      child: const Text('Select CSV File'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}