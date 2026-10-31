
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirestoreStudentsScreen(),
    ),
  );
}

class FirestoreStudentsScreen extends StatefulWidget {
  const FirestoreStudentsScreen({super.key});

  @override
  State<FirestoreStudentsScreen> createState() =>
      _FirestoreStudentsScreenState();
}

class _FirestoreStudentsScreenState
    extends State<FirestoreStudentsScreen> {
  String _selectedCourse = 'All';
  bool _sortAscending = true;

  final List<Map<String, dynamic>> _students = [
    {
      'id': '1',
      'name': 'Aarav Sharma',
      'rollNo': 'BCA01',
      'course': 'BCA',
    },
    {
      'id': '2',
      'name': 'Priya Verma',
      'rollNo': 'BCA02',
      'course': 'BCA',
    },
    {
      'id': '3',
      'name': 'Rohan Patel',
      'rollNo': 'MCA01',
      'course': 'MCA',
    },
  ];

  void _showStudentDialog({
    Map<String, dynamic>? student,
  }) {
    final nameCtrl = TextEditingController(
      text: student?['name'] ?? '',
    );

    final rollCtrl = TextEditingController(
      text: student?['rollNo'] ?? '',
    );

    final courseCtrl = TextEditingController(
      text: student?['course'] ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            student == null ? 'Add Student' : 'Update Student',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rollCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Roll Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: courseCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Course (BCA, MCA, B.Tech)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final roll = rollCtrl.text.trim();
                final course = courseCtrl.text.trim();

                if (name.isEmpty || roll.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter name and roll number',
                      ),
                    ),
                  );
                } else {
                  setState(() {
                    if (student == null) {
                      _students.add({
                        'id': DateTime.now()
                            .microsecondsSinceEpoch
                            .toString(),
                        'name': name,
                        'rollNo': roll,
                        'course':
                        course.isEmpty ? 'BCA' : course,
                      });
                    } else {
                      student['name'] = name;
                      student['rollNo'] = roll;
                      student['course'] =
                      course.isEmpty ? 'BCA' : course;
                    }
                  });

                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      nameCtrl.dispose();
      rollCtrl.dispose();
      courseCtrl.dispose();
    });
  }

  void _deleteStudent(String id) {
    setState(() {
      _students.removeWhere(
            (student) => student['id'] == id,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Student deleted successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayList =
    List<Map<String, dynamic>>.from(_students);

    if (_selectedCourse != 'All') {
      displayList = displayList
          .where(
            (student) =>
        student['course'] == _selectedCourse,
      )
          .toList();
    }

    displayList.sort((a, b) {
      final comparison = (a['name'] as String)
          .compareTo(b['name'] as String);

      return _sortAscending ? comparison : -comparison;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Firestore Students (Lab 9)',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          DropdownButton<String>(
            value: _selectedCourse,
            dropdownColor: Colors.white,
            style: const TextStyle(
              color: Colors.white,
            ),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(
                value: 'All',
                child: Text('All Courses'),
              ),
              DropdownMenuItem(
                value: 'BCA',
                child: Text('BCA'),
              ),
              DropdownMenuItem(
                value: 'MCA',
                child: Text('MCA'),
              ),
              DropdownMenuItem(
                value: 'B.Tech',
                child: Text('B.Tech'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCourse = value;
                });
              }
            },
          ),
          IconButton(
            tooltip: 'Sort by name',
            icon: Icon(
              _sortAscending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
            ),
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
              });
            },
          ),
        ],
      ),
      body: displayList.isEmpty
          ? const Center(
        child: Text(
          'No student records found',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final student = displayList[index];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 5,
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                child: Text(
                  student['name'][0].toUpperCase(),
                ),
              ),
              title: Text(
                '${student['name']} (${student['rollNo']})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Course: ${student['course']}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit student',
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      _showStudentDialog(
                        student: student,
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Delete student',
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _deleteStudent(
                        student['id'],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentDialog(),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        tooltip: 'Add student',
        child: const Icon(Icons.add),
      ),
    );
  }
}
