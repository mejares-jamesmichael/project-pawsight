class Behavior {
  final int id;
  final String name;
  final String category; // Tail, Ears, Eyes, Posture, Vocal
  final String mood; // Happy, Fearful, Aggressive, Relaxed, Mixed
  final String description;
  final String imagePath;

  Behavior({
    required this.id,
    required this.name,
    required this.category,
    required this.mood,
    required this.description,
    required this.imagePath,
  });

  // Convert a Behavior into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'mood': mood,
      'description': description,
      'image_path': imagePath,
    };
  }

  factory Behavior.fromMap(Map<String, dynamic> map) {
    return Behavior(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      mood: map['mood'],
      description: map['description'],
      imagePath: map['image_path'],
    );
  }
}
