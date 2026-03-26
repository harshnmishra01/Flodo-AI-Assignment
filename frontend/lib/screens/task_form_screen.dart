import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = "To-Do";
  int? _blockedBy;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? "");
    _descController = TextEditingController(text: widget.task?.description ?? "");
    
    if (widget.task == null) {
      _loadDraft();
    }
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _titleController.text = prefs.getString('draft_title') ?? "";
      _descController.text = prefs.getString('draft_desc') ?? "";
    });
  }

  Future<void> _saveDraft() async {
    if (widget.task != null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_title', _titleController.text);
    await prefs.setString('draft_desc', _descController.text);
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_title');
    await prefs.remove('draft_desc');
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final allTasks = taskProvider.tasks;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text(widget.task == null ? "New Task" : "Edit Task")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              onChanged: _saveDraft,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: "Description"),
                    maxLines: 3,
                  ),
                  ListTile(
                    title: Text("Due Date: ${_selectedDate.toLocal()}".split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items: ["To-Do", "In Progress", "Done"]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedStatus = val!),
                    decoration: const InputDecoration(labelText: "Status"),
                  ),

                  DropdownButtonFormField<int?>(
                    value: _blockedBy,
                    hint: const Text("Blocked By (Optional)"),
                    items: [
                      const DropdownMenuItem(value: null, child: Text("None")),
                      ...allTasks.where((t) => t.id != widget.task?.id).map(
                        (t) => DropdownMenuItem(value: t.id, child: Text(t.title)),
                      ),
                    ],
                    onChanged: (val) => setState(() => _blockedBy = val),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: taskProvider.isLoading ? null : _submit,
                    child: const Text("Save Task"),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (taskProvider.isLoading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.task?.id,
        title: _titleController.text,
        description: _descController.text,
        dueDate: _selectedDate,
        status: _selectedStatus,
        blockedBy: _blockedBy,
      );

      final msg = widget.task == null 
        ? await context.read<TaskProvider>().addTask(task)
        : await context.read<TaskProvider>().updateTask(task);

      if (mounted) {
        _clearDraft();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        Navigator.pop(context);
      }
    }
  }
}