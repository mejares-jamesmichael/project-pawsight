class Behavior {
  final int id;
  final String name;
  final String category; // Tail, Ears, Eyes, Posture, Vocal
  final String mood; // Happy, Fearful, Aggressive, Relaxed, Mixed
  final String description;
  final String imagePath;
  
  // Source attribution fields
  final String? source; // e.g., "ASPCA", "Cornell Feline Health Center"
  final String? sourceUrl; // Link to original source (can be comma-separated for multiple)
  final String? verifiedBy; // e.g., "Veterinarian-reviewed", "Community-sourced"
  final DateTime? lastUpdated; // When data was added/updated

  Behavior({
    required this.id,
    required this.name,
    required this.category,
    required this.mood,
    required this.description,
    required this.imagePath,
    this.source,
    this.sourceUrl,
    this.verifiedBy,
    this.lastUpdated,
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
      'source': source,
      'source_url': sourceUrl,
      'verified_by': verifiedBy,
      'last_updated': lastUpdated?.toIso8601String(),
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
      source: map['source'],
      sourceUrl: map['source_url'],
      verifiedBy: map['verified_by'],
      lastUpdated: map['last_updated'] != null
          ? DateTime.parse(map['last_updated'])
          : null,
    );
   }
 }


