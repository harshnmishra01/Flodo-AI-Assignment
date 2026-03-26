import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

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
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.createTask(task);
      await loadTasks(); // Refresh list to show new task
      return response['message'] ?? "Task created successfully";
    } catch (e) {
      return "Error: Could not create task";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- UPDATE ---
  Future<String> updateTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.updateTask(task);
      await loadTasks(); // Refresh to update "Blocked" visual states
      return response['message'] ?? "Task updated successfully";
    } catch (e) {
      return "Error: Could not update task";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper for quick status changes (e.g., marking as Done)
  Future<void> toggleTaskStatus(Task task, String newStatus) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      status: newStatus,
      blockedBy: task.blockedBy,
    );
    await updateTask(updatedTask);
  }

  // --- DELETE ---
  Future<String> deleteTask(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      return "Task deleted successfully";
    } catch (e) {
      return "Error: Could not delete task";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}