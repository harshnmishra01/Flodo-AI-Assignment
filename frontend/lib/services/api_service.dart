import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:task_manager/core/api_constants.dart';
import '../models/task.dart';
import '../core/api_constants.dart';

class ApiService {
  // Use a getter to dynamically determine the base URL
  String baseUrl = ApiConstants.baseUrl;

  Future<List<Task>> fetchTasks({String? search, String? status}) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status != 'All') queryParams['status'] = status;

    final uri = Uri.parse(
      "$baseUrl/api/tasks/",
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((item) => Task.fromJson(item)).toList();
      }
      throw Exception('Failed to load tasks');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createTask(Task task) async {
    await Future.delayed(const Duration(seconds: 2));

    final response = await http.post(
      Uri.parse("$baseUrl/api/tasks/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(task.toJson()),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updateTask(Task task) async {
    // REQUIREMENT: 2-second delay on all Updates
    await Future.delayed(const Duration(seconds: 2));

    final response = await http.put(
      Uri.parse("$baseUrl/api/tasks/${task.id}/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(task.toJson()),
    );
    return json.decode(response.body);
  }

  Future<void> deleteTask(int id) async {
    await http.delete(Uri.parse("$baseUrl/api/tasks/$id/"));
  }
}
