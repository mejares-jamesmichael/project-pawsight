/// Model for a cat fact from various fact APIs
///
/// Supports data from:
/// - cat-fact.herokuapp.com
/// - meowfacts.herokuapp.com
class CatFact {
  final String id;
  final String text;
  final String? source;
  final DateTime? updatedAt;

  const CatFact({
    required this.id,
    required this.text,
    this.source,
    this.updatedAt,
  });

  /// Create from cat-fact.herokuapp.com API response
  factory CatFact.fromCatFactApi(Map<String, dynamic> json) {
    return CatFact(
      id: json['_id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['text'] as String,
      source: json['source'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Create from meowfacts.herokuapp.com API response
  factory CatFact.fromMeowFacts(String factText, int index) {
    return CatFact(
      id: 'meow_${DateTime.now().millisecondsSinceEpoch}_$index',
      text: factText,
      source: 'meowfacts',
    );
  }

  @override
  String toString() => 'CatFact(id: $id, text: $text)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatFact && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
