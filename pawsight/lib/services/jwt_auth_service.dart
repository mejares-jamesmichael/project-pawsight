import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for generating JWT tokens for API authentication
///
/// Creates signed JWT tokens that the backend webhook validates
/// before processing requests. Uses HS256 algorithm with a shared secret.
class JwtAuthService {
  static final JwtAuthService _instance = JwtAuthService._internal();

  factory JwtAuthService() => _instance;

  JwtAuthService._internal();

  /// Get the JWT secret from environment variables
  String get _jwtSecret {
    final secret = dotenv.env['JWT_SECRET'];
    if (secret == null || secret.isEmpty) {
      throw JwtAuthException('JWT_SECRET not configured. Please check your .env file.');
    }
    return secret;
  }

  /// Generate a JWT token for API requests
  ///
  /// [userId] - The user's unique identifier to include in the token
  /// [expiresIn] - Token expiration duration (default: 1 hour)
  ///
  /// Returns a signed JWT string to use in Authorization header
  String generateToken({
    required String userId,
    Duration expiresIn = const Duration(hours: 1),
  }) {
    final now = DateTime.now();
    final expiry = now.add(expiresIn);

    // Create JWT payload
    final jwt = JWT(
      {
        'userId': userId,
        'iat': now.millisecondsSinceEpoch ~/ 1000, // Issued at
        'exp': expiry.millisecondsSinceEpoch ~/ 1000, // Expiration
        'iss': 'pawsight-app', // Issuer
        'aud': 'pawsight-api', // Audience
      },
    );

    // Sign with HS256 algorithm using the secret key
    final token = jwt.sign(
      SecretKey(_jwtSecret),
      algorithm: JWTAlgorithm.HS256,
    );

    return token;
  }

  /// Generate authorization header value
  ///
  /// Returns the complete `Bearer <token>` string for HTTP headers
  String getAuthorizationHeader({required String userId}) {
    final token = generateToken(userId: userId);
    return 'Bearer $token';
  }

  /// Verify a JWT token (for testing purposes)
  ///
  /// Returns the decoded payload if valid, throws exception if invalid
  Map<String, dynamic> verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_jwtSecret));
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException {
      throw JwtAuthException('Token has expired.');
    } on JWTInvalidException catch (e) {
      throw JwtAuthException('Invalid token: ${e.message}');
    } catch (e) {
      throw JwtAuthException('Token verification failed: $e');
    }
  }
}

/// Custom exception for JWT authentication errors
class JwtAuthException implements Exception {
  final String message;

  JwtAuthException(this.message);

  @override
  String toString() => 'JwtAuthException: $message';
}
