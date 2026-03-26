import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for iOS Simulator/Web
  final String baseUrl = Platform.isAndroid 
      ? "http://10.0.2.2:8000/api" 
      : "http://127.0.0.1:8000/api";

  Future<List<Task>> fetchTasks({String? search, String? status}) async {
    String url = "$baseUrl/tasks/";
    Map<String, String> params = {};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (status != null && status != 'All') params['status'] = status;
    
    final uri = Uri.parse(url).replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => Task.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Map<String, dynamic>> createTask(Task task) async {
    await Future.delayed(const Duration(seconds: 2));

    final response = await http.post(
      Uri.parse("$baseUrl/tasks/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(task.toJson()),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updateTask(Task task) async {
    // REQUIREMENT: 2-second delay on all Updates
    await Future.delayed(const Duration(seconds: 2));

    final response = await http.put(
      Uri.parse("$baseUrl/tasks/${task.id}/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(task.toJson()),
    );
    return json.decode(response.body);
  }

  Future<void> deleteTask(int id) async {
    await http.delete(Uri.parse("$baseUrl/tasks/$id/"));
  }
}