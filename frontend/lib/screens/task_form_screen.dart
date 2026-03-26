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
  late DateTime _selectedDate;
  late String _selectedStatus;
  int? _blockedBy;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? "");
    _descController = TextEditingController(text: widget.task?.description ?? "");

    // Attach listeners to save drafts instantly on every keystroke
    _titleController.addListener(_saveDraft);
    _descController.addListener(_saveDraft);

    _selectedDate = widget.task?.dueDate ?? DateTime.now();
    _selectedStatus = widget.task?.status ?? "To-Do";
    _blockedBy = widget.task?.blockedBy;

    // Only load drafts if we are creating a NEW task
    if (widget.task == null) {
      _loadDraft();
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_saveDraft);
    _descController.removeListener(_saveDraft);
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- DRAFTS LOGIC (Requirement) ---
  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _titleController.text = prefs.getString('draft_title') ?? "";
      _descController.text = prefs.getString('draft_desc') ?? "";
    });
  }

  Future<void> _saveDraft() async {
    // Don't overwrite drafts if we are editing an existing task
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
    
    // NEW: Use isSaving to manage button state without freezing the UI
    final isSaving = taskProvider.isSaving; 

    // Filter out "Done" tasks and the current task itself from the blockers list
    final validBlockers = allTasks
        .where((t) => t.id != widget.task?.id && t.status != "Done")
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? "New Task" : "Edit Task"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) => v!.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Due Date"),
                subtitle: Text(
                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const Divider(),
              const SizedBox(height: 8),
              
              // --- STATUS DROPDOWN ---
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: ["To-Do", "In Progress", "Done"]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedStatus = val!;
                    // NEW LOGIC: A "Done" task cannot be blocked.
                    // Clear the blocker instantly on selection change.
                    if (_selectedStatus == "Done") {
                      _blockedBy = null;
                    }
                  });
                },
                decoration: const InputDecoration(labelText: "Status"),
              ),
              const SizedBox(height: 12),

              // --- BLOCKED BY DROPDOWN (Requirement) ---
              // A task can only be blocked if it is NOT Done.
              DropdownButtonFormField<int?>(
                // Use a proper theme-aware style, not a fixed bright patch.
                value: (_selectedStatus != "Done" && validBlockers.any((t) => t.id == _blockedBy))
                    ? _blockedBy
                    : null,
                decoration: const InputDecoration(
                  labelText: "Blocked By (Optional)",
                  // Removed explicit fillColor. The theme handles the disabled look.
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text("None — not blocked")),
                  ...validBlockers.map(
                    (t) => DropdownMenuItem(value: t.id, child: Text(t.title)),
                  ),
                ],
                // NEW LOGIC: Disable completely if the task status is "Done"
                // This triggers Flutter's native "disabled" style.
                onChanged: _selectedStatus != "Done" 
                    ? (val) => setState(() => _blockedBy = val)
                    : null,
              ),
              const SizedBox(height: 40),

              // --- SAVE BUTTON LOGIC (Requirement) ---
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  // LOCKOUT: If saving, onPressed is null to prevent double tap
                  onPressed: isSaving ? null : _submit, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    disabledBackgroundColor: Colors.grey[400],
                  ),
                  child: isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text("Saving...", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        )
                      : const Text("Save Task", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.task?.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        dueDate: _selectedDate,
        status: _selectedStatus,
        blockedBy: _blockedBy,
      );

      final taskProvider = context.read<TaskProvider>();

      final msg = widget.task == null
          ? await taskProvider.addTask(task)
          : await taskProvider.updateTask(task);

      if (mounted) {
        // Clear the draft only on successful save
        _clearDraft();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        Navigator.pop(context);
      }
    }
  }
}