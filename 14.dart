
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: CloudNotesScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class CloudNotesScreen extends StatefulWidget {
  const CloudNotesScreen({super.key});

  @override
  State<CloudNotesScreen> createState() => _CloudNotesScreenState();
}

class _CloudNotesScreenState extends State<CloudNotesScreen> {

  final List<Map<String, String>> _notes = [
    {
      'id': '1',
      'title': 'Flutter Firestore Integration',
      'content': 'Implement collection reference, add, view and delete operations.',
    },
    {
      'id': '2',
      'title': 'Lab 10 Program 14',
      'content': 'Cloud notes management system.',
    },
  ];

  void _showAddNoteDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Cloud Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              final content = contentCtrl.text.trim();

              if (title.isNotEmpty) {
                setState(() {
                  _notes.insert(0, {
                    'id': DateTime.now()
                        .millisecondsSinceEpoch.toString(),
                    'title': title,
                    'content': content,
                  });
                });

                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteNote(String id) {
    setState(() {
      _notes.removeWhere((item) => item['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Notes (Prog 14)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: _notes.isEmpty
          ? const Center(
        child: Text('No notes found. Tap + to add one.'),
      )
          : ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (ctx, i) {
          final note = _notes[i];

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.note),
              ),
              title: Text(
                note['title'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(note['content'] ?? ''),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () => _deleteNote(note['id']!),
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        child: const Icon(Icons.note_add),
      ),
    );
  }
}
