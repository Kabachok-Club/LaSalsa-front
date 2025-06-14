class Task {
  final String id;
  final String name;
  final String description;
  final String status;
  final DateTime? plannedAt; 


  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    this.plannedAt,

    
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'TODO',
      plannedAt: json['planned_at'] != null
        ?DateTime.parse(json['planned_at'])
        : null,
    );
  }
}
