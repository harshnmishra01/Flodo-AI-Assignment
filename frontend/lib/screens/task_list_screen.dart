import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/widgets/highlighted_text.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'task_form_screen.dart';
import 'dart:async';
import 'package:intl/intl.dart';

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
        title: const Text(
          "Tasks Dashboard",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Color.fromARGB(255, 233, 229, 229),
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
              child: CustomScrollView(
                slivers: [
                  // Search bar + filter chips as a sticky header in the body
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search bar
                          TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: "Search tasks...",
                              hintStyle: const TextStyle(color: Colors.black45),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.black45,
                              ),
                              suffixIcon: _hasSearchText
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Colors.black45,
                                      ),
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
                              fillColor: const Color.fromARGB(
                                255,
                                237,
                                234,
                                234,
                              ),
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
                          const SizedBox(height: 12),
                          // Filter chips — using Wrap so they never get clipped
                          Wrap(
                            spacing: 8,
                            children: ["All", "To-Do", "In Progress", "Done"]
                                .map((status) {
                                  final isSelected = _statusFilter == status;
                                  return ChoiceChip(
                                    label: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected ? Colors.white : null,
                                      ),
                                    ),
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
                                  );
                                })
                                .toList(),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                  // Task list
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final task = taskProvider.tasks[index];
                      final isBlocked = _checkIfBlocked(task, taskProvider);
                      final blockerName = _getBlockerName(task, taskProvider);
                      return _buildTaskCard(
                        context,
                        task,
                        isBlocked,
                        blockerName,
                        taskProvider,
                      );
                    }, childCount: taskProvider.tasks.length),
                  ),
                ],
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

  Widget _buildTaskCard(
    BuildContext context,
    Task task,
    bool isBlocked,
    String? blockerName,
    TaskProvider taskProvider,
  ) {
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
            content: const Text("Are you sure you want to remove this task?"),
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
        // 1. Remember where the task was, in case we need to put it back
        final int taskIndex = taskProvider.tasks.indexOf(task);

        // 2. Remove it from the UI immediately
        taskProvider.removeTaskLocally(task.id!);

        // 3. Clear existing SnackBars to prevent them from stacking up
        ScaffoldMessenger.of(context).clearSnackBars();

        // 4. Show the SnackBar with the Undo button
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: const Text("Task deleted"),
                duration: const Duration(
                  seconds: 4,
                ), // Gives them a moment to react
                action: SnackBarAction(
                  label: 'UNDO',
                  textColor: Colors
                      .blueAccent, // Make it pop against the dark snackbar
                  onPressed: () {
                    // User clicked Undo: put it back instantly!
                    taskProvider.insertTaskLocally(task, taskIndex);
                  },
                ),
              ),
            )
            .closed
            .then((reason) {
              // 5. If the SnackBar closed naturally (timeout, swiped away)
              // and NOT because they clicked the Undo action, delete it for real.
              if (reason != SnackBarClosedReason.action) {
                taskProvider.commitDeleteToAPI(task.id!);
              }
            });
      },
      child: Opacity(
        opacity: isBlocked ? 0.5 : 1.0,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                decoration: isBlocked ? TextDecoration.lineThrough : null,
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
                      "Due: ${DateFormat('dd MMM yyyy').format(task.dueDate)}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
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
                        builder: (context) => TaskFormScreen(task: task),
                      ),
                    );
                  },
          ),
        ),
      ),
    );
  }
}
