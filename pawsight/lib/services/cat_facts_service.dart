import '../models/cat_fact.dart';
import 'base_api_service.dart';

/// Service for fetching cat facts from multiple sources
///
/// Supports:
/// - cat-fact.herokuapp.com (primary)
/// - meowfacts.herokuapp.com (fallback)
class CatFactsService extends BaseApiService {
  static const String _catFactBaseUrl = 'https://cat-fact.herokuapp.com';
  static const String _meowFactsBaseUrl = 'https://meowfacts.herokuapp.com';

  @override
  String get baseUrl => _catFactBaseUrl;

  static final CatFactsService _instance = CatFactsService._internal();

  factory CatFactsService() => _instance;

  CatFactsService._internal();

  /// Get random cat facts
  ///
  /// [amount] - Number of facts to retrieve (1-500, default 1)
  ///
  /// Returns a list of [CatFact] objects
  /// Falls back to meowfacts if primary API fails
  Future<List<CatFact>> getRandomFacts({int amount = 1}) async {
    try {
      return await _getFactsFromCatFactApi(amount);
    } on ApiException {
      // Fallback to meowfacts API
      return await _getFactsFromMeowFacts(amount);
    }
  }

  /// Get a single random cat fact
  Future<CatFact> getRandomFact() async {
    final facts = await getRandomFacts(amount: 1);
    return facts.first;
  }

  /// Get facts from cat-fact.herokuapp.com
  Future<List<CatFact>> _getFactsFromCatFactApi(int amount) async {
    final response = await get(
      '/facts/random',
      queryParams: {
        'animal_type': 'cat',
        'amount': amount.toString(),
      },
    );

    // Single fact returns object, multiple returns array
    if (response is List) {
      return response
          .map((json) => CatFact.fromCatFactApi(json as Map<String, dynamic>))
          .toList();
    } else if (response is Map<String, dynamic>) {
      return [CatFact.fromCatFactApi(response)];
    }

    throw ApiException('Invalid response format from cat facts API');
  }

  /// Get facts from meowfacts.herokuapp.com (fallback)
  Future<List<CatFact>> _getFactsFromMeowFacts(int amount) async {
    final response = await get(
      _meowFactsBaseUrl,
      queryParams: {'count': amount.toString()},
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      final data = response['data'] as List<dynamic>;
      return data
          .asMap()
          .entries
          .map((entry) => CatFact.fromMeowFacts(entry.value as String, entry.key))
          .toList();
    }

    throw ApiException('Invalid response format from meowfacts API');
  }

  /// Get a fact by its ID (cat-fact.herokuapp.com only)
  Future<CatFact> getFactById(String factId) async {
    final response = await get('/facts/$factId');

    if (response is Map<String, dynamic>) {
      return CatFact.fromCatFactApi(response);
    }

    throw ApiException('Invalid response format');
  }
}
