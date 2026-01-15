/// Model for cat breed information from TheCatAPI
///
/// API: https://api.thecatapi.com
class CatBreed {
  final String id;
  final String name;
  final String? temperament;
  final String? origin;
  final String? description;
  final String? lifeSpan;
  final String? wikipediaUrl;
  final CatWeight? weight;
  final int? adaptability;
  final int? affectionLevel;
  final int? childFriendly;
  final int? dogFriendly;
  final int? energyLevel;
  final int? grooming;
  final int? healthIssues;
  final int? intelligence;
  final int? sheddingLevel;
  final int? socialNeeds;
  final int? strangerFriendly;
  final int? vocalisation;
  final String? imageId;

  const CatBreed({
    required this.id,
    required this.name,
    this.temperament,
    this.origin,
    this.description,
    this.lifeSpan,
    this.wikipediaUrl,
    this.weight,
    this.adaptability,
    this.affectionLevel,
    this.childFriendly,
    this.dogFriendly,
    this.energyLevel,
    this.grooming,
    this.healthIssues,
    this.intelligence,
    this.sheddingLevel,
    this.socialNeeds,
    this.strangerFriendly,
    this.vocalisation,
    this.imageId,
  });

  factory CatBreed.fromJson(Map<String, dynamic> json) {
    return CatBreed(
      id: json['id'] as String,
      name: json['name'] as String,
      temperament: json['temperament'] as String?,
      origin: json['origin'] as String?,
      description: json['description'] as String?,
      lifeSpan: json['life_span'] as String?,
      wikipediaUrl: json['wikipedia_url'] as String?,
      weight: json['weight'] != null
          ? CatWeight.fromJson(json['weight'] as Map<String, dynamic>)
          : null,
      adaptability: json['adaptability'] as int?,
      affectionLevel: json['affection_level'] as int?,
      childFriendly: json['child_friendly'] as int?,
      dogFriendly: json['dog_friendly'] as int?,
      energyLevel: json['energy_level'] as int?,
      grooming: json['grooming'] as int?,
      healthIssues: json['health_issues'] as int?,
      intelligence: json['intelligence'] as int?,
      sheddingLevel: json['shedding_level'] as int?,
      socialNeeds: json['social_needs'] as int?,
      strangerFriendly: json['stranger_friendly'] as int?,
      vocalisation: json['vocalisation'] as int?,
      imageId: json['reference_image_id'] as String?,
    );
  }

  /// Get temperament as a list of traits
  List<String> get temperamentList {
    if (temperament == null) return [];
    return temperament!.split(',').map((e) => e.trim()).toList();
  }

  @override
  String toString() => 'CatBreed(id: $id, name: $name)';
}

/// Weight information for cat breeds
class CatWeight {
  final String? imperial;
  final String? metric;

  const CatWeight({this.imperial, this.metric});

  factory CatWeight.fromJson(Map<String, dynamic> json) {
    return CatWeight(
      imperial: json['imperial'] as String?,
      metric: json['metric'] as String?,
    );
  }

  @override
  String toString() => 'CatWeight(metric: $metric, imperial: $imperial)';
}

/// Model for cat images from TheCatAPI
class TheCatApiImage {
  final String id;
  final String url;
  final int? width;
  final int? height;
  final List<CatBreed> breeds;

  const TheCatApiImage({
    required this.id,
    required this.url,
    this.width,
    this.height,
    this.breeds = const [],
  });

  factory TheCatApiImage.fromJson(Map<String, dynamic> json) {
    return TheCatApiImage(
      id: json['id'] as String,
      url: json['url'] as String,
      width: json['width'] as int?,
      height: json['height'] as int?,
      breeds: (json['breeds'] as List<dynamic>?)
              ?.map((e) => CatBreed.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Check if this image has breed information
  bool get hasBreedInfo => breeds.isNotEmpty;

  @override
  String toString() => 'TheCatApiImage(id: $id, url: $url)';
}
