import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'task_form_screen.dart'; // We will create this next

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _searchQuery = "";
  String _statusFilter = "All";

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flodo Tasks"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // SEARCH BAR
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Search tasks...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    taskProvider.loadTasks(search: val, status: _statusFilter);
                  },
                ),
                const SizedBox(height: 8),
                // STATUS FILTER
                DropdownButton<String>(
                  isExpanded: true,
                  value: _statusFilter,
                  items: ["All", "To-Do", "In Progress", "Done"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _statusFilter = val!);
                    taskProvider.loadTasks(search: _searchQuery, status: val);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: taskProvider.isLoading && taskProvider.tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => taskProvider.loadTasks(
                  search: _searchQuery, status: _statusFilter),
              child: ListView.builder(
                itemCount: taskProvider.tasks.length,
                itemBuilder: (context, index) {
                  final task = taskProvider.tasks[index];
                  
                  // BLOCKED LOGIC: Check if the blocker task is NOT "Done"
                  bool isBlocked = false;
                  if (task.blockedBy != null) {
                    final blocker = taskProvider.getTaskById(task.blockedBy!);
                    if (blocker != null && blocker.status != "Done") {
                      isBlocked = true;
                    }
                  }

                  return Opacity(
                    opacity: isBlocked ? 0.5 : 1.0, // Greyed out look
                    child: Card(
                      margin: const EdgeInsets.all(8),
                      color: isBlocked ? Colors.grey[200] : Colors.white,
                      child: ListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: isBlocked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text("${task.status} • Due: ${task.dueDate.toLocal()}".split(' ')[0]),
                        trailing: isBlocked ? const Icon(Icons.lock) : const Icon(Icons.chevron_right),
                        onTap: isBlocked ? null : () {
                           // Navigate to Edit
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TaskFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}