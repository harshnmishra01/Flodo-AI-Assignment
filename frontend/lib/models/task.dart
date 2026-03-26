class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status;
  final int? blockedBy;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedBy,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // Check if data is nested under 'data' key from our custom Django response
    var data = json.containsKey('data') ? json['data'] : json;
    return Task(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      dueDate: DateTime.parse(data['due_date']),
      status: data['status'],
      blockedBy: data['blocked_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "due_date": "${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}",
      "status": status,
      "blocked_by": blockedBy,
    };
  }
}