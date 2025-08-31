import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cycle2_internship_app/services/storage_helper.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../models/task.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const HomeScreen({super.key, required this.toggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskController = TextEditingController();

  void _addTask(TaskProvider provider) {
    if (_taskController.text.isEmpty) return;
    provider.addTask(Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _taskController.text,
    ));
    _taskController.clear();
  }

  Future<void> _logout() async {
    await StorageHelper.clearLoginState();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(onLogin: () async {
          await StorageHelper.saveLoginState(true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(toggleTheme: widget.toggleTheme),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'New Task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addTask(taskProvider),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, child) {
                final tasks = provider.tasks;
                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks yet!'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskTile(task: task);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
