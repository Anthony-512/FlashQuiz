import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/subject.dart';
import '../providers/quiz_provider.dart';
import 'subject_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  Color _selectedColor = Colors.blue;

  void _createSubject() {
    if (_formKey.currentState!.validate()) {
      final subject = Subject(
        id: const Uuid().v4(),
        name: _controller.text,
        colorValue: _selectedColor.value,
      );
      Provider.of<QuizProvider>(context, listen: false).addSubject(subject);
      Navigator.pop(context);
      _controller.clear();
    }
  }
  
  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(  // Add StatefulBuilder to manage local dialog state
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create New Subject'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(labelText: 'Subject Name'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    const Text('Select Color'),
                    Wrap(
                      children: Colors.primaries.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;  // Update the selected color
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            width: 40,
                            height: 40,
                            color: color,
                            child: _selectedColor == color
                                ? Icon(
                                    Icons.check,
                                    color: color.computeLuminance() > 0.5 
                                        ? Colors.black  // Use black check for light colors
                                        : Colors.white, // Use white check for dark colors
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _createSubject,
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _promptUsername() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<QuizProvider>(context, listen: false).setUsername(controller.text);
                Navigator.pop(context);
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
      appBar: AppBar(
        title: Consumer<QuizProvider>(  // Wrap title in Consumer for live updates
          builder: (context, provider, child) {
            final username = provider.currentUsername ?? 'Guest';  // Fallback if not set
            return Text('$username\'s Subjects');  // Displays e.g., "Alice's Subjects"
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 32),
            onPressed: _promptUsername,
            tooltip: 'Change Username',
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard, size: 32),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<QuizProvider>( // Wrapped in Consumer for reactive updates
        builder: (context, provider, child) {
          final subjects = provider.subjects;
          print('Home screen subjects count: ${subjects.length}'); // Debugging log
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubjectScreen(subject: subject),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(subject.colorValue),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),  // Add padding for better appearance
                      child: Text(
                        subject.name,
                        textAlign: TextAlign.center,  // Add this line
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}