import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/widgets/highlighted_text.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'task_form_screen.dart';
import 'dart:async';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _searchQuery = "";
  String _statusFilter = "All";
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearchText = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Done':
        color = Colors.green;
        break;
      case 'In Progress':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  bool _checkIfBlocked(Task task, TaskProvider provider) {
    if (task.blockedBy == null) return false;
    final blocker = provider.getTaskById(task.blockedBy!);
    return (blocker != null && blocker.status != "Done");
  }

  // FIX: Returns the blocker task title if the task is actively blocked
  String? _getBlockerName(Task task, TaskProvider provider) {
    if (task.blockedBy == null) return null;
    final blocker = provider.getTaskById(task.blockedBy!);
    if (blocker != null && blocker.status != "Done") return blocker.title;
    return null;
  }

  _onSearchChanged(String query, TaskProvider provider) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = query);
      provider.loadTasks(search: query, status: _statusFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flodo Tasks Dashboard"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // FIX: Search bar with proper text color and clear button
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Search tasks...",
                    hintStyle: const TextStyle(color: Colors.black45),
                    prefixIcon: const Icon(Icons.search, color: Colors.black45),
                    suffixIcon: _hasSearchText
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.black45),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = "";
                                _hasSearchText = false;
                              });
                              taskProvider.loadTasks(
                                search: "",
                                status: _statusFilter,
                              );
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _hasSearchText = val.isNotEmpty);
                    _onSearchChanged(val, taskProvider);
                  },
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ["All", "To-Do", "In Progress", "Done"].map((status) {
                      final isSelected = _statusFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(status),
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : null,
                          ),
                          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _statusFilter = status);
                              taskProvider.loadTasks(
                                search: _searchQuery,
                                status: status,
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
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
                search: _searchQuery,
                status: _statusFilter,
              ),
              child: ListView.builder(
                itemCount: taskProvider.tasks.length,
                itemBuilder: (context, index) {
                  final task = taskProvider.tasks[index];
                  final isBlocked = _checkIfBlocked(task, taskProvider);
                  // FIX: Get the name of the blocking task
                  final blockerName = _getBlockerName(task, taskProvider);

                  return Dismissible(
                    key: Key(task.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Task?"),
                          content: const Text(
                            "Are you sure you want to remove this task?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      taskProvider.deleteTask(task.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Task deleted")),
                      );
                    },
                    child: Opacity(
                      opacity: isBlocked ? 0.5 : 1.0,
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        elevation: isBlocked ? 0 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: HighlightedText(
                            fullText: task.title,
                            query: _searchQuery,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              decoration: isBlocked
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildStatusChip(task.status),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              // FIX: Show the blocker's name if this task is blocked
                              if (blockerName != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.lock_outline,
                                      size: 12,
                                      color: Colors.redAccent,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "Blocked by: $blockerName",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.redAccent,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: isBlocked
                              ? const Icon(Icons.lock_outline, color: Colors.grey)
                              : const Icon(Icons.chevron_right),
                          onTap: isBlocked
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TaskFormScreen(task: task),
                                    ),
                                  );
                                },
                        ),
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