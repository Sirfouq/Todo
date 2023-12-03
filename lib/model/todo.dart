class Todo {
  final int? id;
  String description;
  bool isCompleted;

  Todo({required this.id, required this.description, required this.isCompleted});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1, // Assuming you store booleans as int (1 or 0) in SQLite
    );
  }
}
