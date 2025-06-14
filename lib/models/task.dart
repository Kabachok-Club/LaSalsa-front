class Task {
  final String id;
  final String name;
  final String description;
  final String status;
  final DateTime createdAt; 


  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,

    
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'TODO',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
