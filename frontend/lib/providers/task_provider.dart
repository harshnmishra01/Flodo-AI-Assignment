import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  bool _isSaving = false; // NEW: Specific state to lock the Save button
  final ApiService _apiService = ApiService();

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving; // NEW: Getter for the UI

  // --- READ ---
  Task? getTaskById(int id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadTasks({String? search, String? status}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await _apiService.fetchTasks(search: search, status: status);
    } catch (e) {
      debugPrint("Error loading tasks: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- CREATE ---
  Future<String> addTask(Task task) async {
    _isSaving = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    try {
      final response = await _apiService.createTask(task);
      await loadTasks(); // Refresh list to show new task
      return response['message'] ?? "Task created successfully";
    } catch (e) {
      return "Error: Could not create task";
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // --- UPDATE ---
  Future<String> updateTask(Task task) async {
    _isSaving = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    try {
      final response = await _apiService.updateTask(task);
      await loadTasks(); // Refresh to update "Blocked" visual states
      return response['message'] ?? "Task updated successfully";
    } catch (e) {
      return "Error: Could not update task";
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Helper for quick status changes (e.g., marking as Done via swipe)
  Future<void> toggleTaskStatus(Task task, String newStatus) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      status: newStatus,
      blockedBy: task.blockedBy,
    );
    // This will naturally include the 2-second delay because it calls updateTask
    await updateTask(updatedTask);
  }

  // // --- DELETE ---
  // Future<String> deleteTask(int id) async {
  //   // 1. Find and save the task in case the API call fails and we need to restore it
  //   final taskIndex = _tasks.indexWhere((t) => t.id == id);
  //   if (taskIndex == -1) return "Error: Task not found";
  //   final taskToRestore = _tasks[taskIndex];

  //   // 2. Synchronously remove the task and update the UI IMMEDIATELY
  //   _tasks.removeAt(taskIndex);
  //   notifyListeners(); // <-- This instantly updates the tree, fixing the Dismissible error!

  //   try {
  //     // 3. Perform the asynchronous API call in the background
  //     await _apiService.deleteTask(id);
  //     return "Task deleted successfully";
  //   } catch (e) {
  //     // 4. If the API fails, insert the task back into the list at its original spot
  //     _tasks.insert(taskIndex, taskToRestore);
  //     notifyListeners(); // Tell the UI the task is back
  //     return "Error: Could not delete task";
  //   }
  // }

  // 1. Instantly removes the task from the screen
  void removeTaskLocally(int id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // 2. Puts the task back if the user clicks "Undo"
  void insertTaskLocally(Task task, int index) {
    // Ensure we don't insert out of bounds if the list changed
    final safeIndex = index > _tasks.length ? _tasks.length : index;
    _tasks.insert(safeIndex, task);
    notifyListeners();
  }

  // 3. Actually tells the backend to delete it (called after SnackBar disappears)
  Future<void> commitDeleteToAPI(int id) async {
    try {
      await _apiService.deleteTask(id);
    } catch (e) {
      // Optional: Handle API failure here (e.g., fetch tasks again to resync)
      print("Failed to delete from API: $e");
    }
  }

  // NEW: Fetch all tasks specifically for the dropdown, bypassing local filters
  Future<List<Task>> fetchAllTasksForDropdown() async {
    try {
      return await _apiService.fetchTasks(); // No status filter
    } catch (e) {
      debugPrint("Error fetching all tasks: $e");
      return [];
    }
  }
}
