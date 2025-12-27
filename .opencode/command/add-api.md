# /add-api Command

**Syntax**: `/add-api {api_name} {base_url}`

**Description**: Integrates a new external API with proper error handling, models, and service layer.

**Example**: `/add-api cat-facts https://catfact.ninja`

## What This Command Does

Creates a complete API integration following best practices:
- HTTP service class with timeout and error handling
- Response model classes with JSON serialization
- Example usage in Provider
- Offline fallback strategies

## Usage

```bash
/add-api {api-name} {base-url}
```

### Examples

```bash
/add-api cat-facts https://catfact.ninja
# Creates: CatFactsService, CatFact model

/add-api cataas https://cataas.com
# Creates: CataasService, CatImage model

/add-api pet-finder https://api.petfinder.com
# Creates: PetFinderService with auth support
```

## What Gets Created

### 1. Service Class
**Location**: `lib/services/{api_name}_service.dart`

```dart
class {ApiName}Service {
  static final {ApiName}Service _instance = {ApiName}Service._internal();
  factory {ApiName}Service() => _instance;
  {ApiName}Service._internal();
  
  static const String _baseUrl = '{base_url}';
  static const Duration _timeout = Duration(seconds: 10);
  
  Future<{ResponseModel}> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/endpoint'))
          .timeout(_timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {ResponseModel}.fromJson(data);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }
}
```

### 2. Response Models
**Location**: `lib/models/{api_name}_models.dart`

```dart
class {ModelName} {
  final String id;
  final String data;
  
  const {ModelName}({required this.id, required this.data});
  
  factory {ModelName}.fromJson(Map<String, dynamic> json) {
    return {ModelName}(
      id: json['id'] as String,
      data: json['data'] as String,
    );
  }
}
```

### 3. Example Provider Integration

Shows how to use the service in a Provider.

## Error Handling Included

- **Network errors**: User-friendly messages
- **Timeout errors**: 10-second timeout configured
- **Parse errors**: Caught and logged
- **HTTP errors**: Status code validation

## When to Use

- Integrating cat/pet APIs (Cat Facts, Cataas, MeowFacts, etc.)
- Adding n8n webhook communication
- Connecting to any REST API

## Authentication Support

The agent automatically detects and implements:
- API keys in headers
- API keys in query parameters
- OAuth tokens
- No authentication

## Routing

This command routes to the **API Integration Specialist** agent with:
- Context: API integration process, error handling standards
- Templates: HTTP service templates
- Working directory: `pawsight/`

## After Execution

1. **Test API**: Verify endpoint works
2. **Integrate with Provider**: Create or update Provider to use service
3. **Add tests**: Mock API responses for unit tests
4. **Review**: `/review-code lib/services/{api}_service.dart`

## Special Cases

### n8n Webhook (Multipart)

```bash
/add-api n8n-chat https://your-n8n-webhook-url
```

Automatically creates multipart request support for text + image uploads.

### APIs Requiring Authentication

```bash
/add-api petfinder https://api.petfinder.com
```

Agent will prompt for API key location and implement authentication.

## Related Commands

- `/build-feature` - Create feature that uses the API
- `/review-code` - Review generated service code
