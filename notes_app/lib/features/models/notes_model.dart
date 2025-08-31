class NotesModel {
  final String? id;
  final String? title;
  final String? description;
  final String? userId;
  final int? createAt;
  String? color; // Add color field

  NotesModel({
    this.id,
    this.title,
    this.description,
    this.userId,
    this.createAt,
    this.color, // Add to constructor
  });

  // Factory constructor to create NotesModel from JSON
  factory NotesModel.fromJson(Map<String, dynamic> json) {
    return NotesModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      userId: json['userId'] ?? '',
      createAt: json['createAt'] ?? 0,
      color: json['color'], // Add color parsing
    );
  }

  // Method to convert NotesModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'createAt': createAt,
      'color': color, // Add color to JSON
    };
  }

  // Method to convert to JSON for creating new notes (without _id)
  Map<String, dynamic> toJsonForCreate() {
    return {'title': title, 'description': description, 'userId': userId};
  }

  // CopyWith method for immutable updates
  NotesModel copyWith({
    String? id,
    String? title,
    String? description,
    String? userId,
    int? createAt,
  }) {
    return NotesModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      createAt: createAt ?? this.createAt,
    );
  }

  @override
  String toString() {
    return 'NotesModel(id: $id, title: $title, description: $description, userId: $userId, createAt: $createAt)';
  }
}
