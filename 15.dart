
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MaterialApp(
    home: StudentAppGate(),
    debugShowCheckedModeBanner: false,
  ));
}

// Student App Gate
class StudentAppGate extends StatelessWidget {
  const StudentAppGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const StudentManagementDashboard();
        }

        return const AuthPage();
      },
    );
  }
}

// Login and Registration Page
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  bool isLogin = true;

  Future<void> _submit() async {
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _pass.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _pass.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication Error')),
      );
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login to Portal' : 'Register Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(isLogin ? 'Login' : 'Register'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(
                isLogin
                    ? 'Need an account? Register'
                    : 'Have an account? Login',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Student Management Dashboard
class StudentManagementDashboard extends StatefulWidget {
  const StudentManagementDashboard({super.key});

  @override
  State<StudentManagementDashboard> createState() =>
      _StudentManagementDashboardState();
}

class _StudentManagementDashboardState
    extends State<StudentManagementDashboard> {

  final CollectionReference<Map<String, dynamic>> _students =
  FirebaseFirestore.instance.collection('students');

  void _openFormModal({DocumentSnapshot<Map<String, dynamic>>? doc}) {
    final name = TextEditingController(
      text: doc?.data()?['name'] ?? '',
    );

    final roll = TextEditingController(
      text: doc?.data()?['rollNo'] ?? '',
    );

    final course = TextEditingController(
      text: doc?.data()?['course'] ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              doc == null ? 'Add Student Record' : 'Edit Student Record',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: roll,
              decoration: const InputDecoration(labelText: 'Roll Number'),
            ),
            TextField(
              controller: course,
              decoration: const InputDecoration(labelText: 'Course'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (name.text.trim().isNotEmpty &&
                    roll.text.trim().isNotEmpty) {
                  if (doc == null) {
                    await _students.add({
                      'name': name.text.trim(),
                      'rollNo': roll.text.trim(),
                      'course': course.text.trim(),
                    });
                  } else {
                    await _students.doc(doc.id).update({
                      'name': name.text.trim(),
                      'rollNo': roll.text.trim(),
                      'course': course.text.trim(),
                    });
                  }

                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                }
              },
              child: Text(doc == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _students.snapshots(),
        builder: (ctx, snap) {
          if (snap.hasError) {
            return const Center(
              child: Text('Something went wrong.'),
            );
          }

          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final items = snap.data!.docs;

          if (items.isEmpty) {
            return const Center(
              child: Text('No student records found.'),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (c, i) {
              final student = items[i];
              final data = student.data();

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    (data['name'] ?? 'S')[0].toUpperCase(),
                  ),
                ),
                title: Text(
                  '${data['name']} (${data['rollNo']})',
                ),
                subtitle: Text(data['course'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _openFormModal(doc: student),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _students.doc(student.id).delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openFormModal(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
