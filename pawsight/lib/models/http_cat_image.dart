/// Model for HTTP status cat images from http.cat
///
/// API: https://http.cat
class HttpCatImage {
  final int statusCode;
  final String statusText;
  final String imageUrl;

  const HttpCatImage({
    required this.statusCode,
    required this.statusText,
    required this.imageUrl,
  });

  /// Create from status code
  factory HttpCatImage.fromStatusCode(int statusCode) {
    return HttpCatImage(
      statusCode: statusCode,
      statusText: _statusTexts[statusCode] ?? 'Unknown Status',
      imageUrl: 'https://http.cat/$statusCode',
    );
  }

  /// Get image URL with .jpg extension (for compatibility)
  String get imageUrlWithExtension => 'https://http.cat/$statusCode.jpg';

  /// All available HTTP status codes with cat images
  static const List<int> availableStatusCodes = [
    100, 101, 102, 103,
    200, 201, 202, 203, 204, 205, 206, 207, 208, 214, 226,
    300, 301, 302, 303, 304, 305, 307, 308,
    400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410,
    411, 412, 413, 414, 415, 416, 417, 418, 419, 420, 421,
    422, 423, 424, 425, 426, 428, 429, 431, 444, 450, 451,
    495, 496, 497, 498, 499,
    500, 501, 502, 503, 504, 506, 507, 508, 509, 510, 511,
    521, 522, 523, 525, 530, 599,
  ];

  /// Common/popular status codes for quick access
  static const List<int> popularStatusCodes = [
    200, 201, 204,
    301, 302, 304,
    400, 401, 403, 404, 405,
    418, 429,
    500, 502, 503, 504,
  ];

  /// HTTP status text mapping
  static const Map<int, String> _statusTexts = {
    100: 'Continue',
    101: 'Switching Protocols',
    102: 'Processing',
    103: 'Early Hints',
    200: 'OK',
    201: 'Created',
    202: 'Accepted',
    203: 'Non-Authoritative Information',
    204: 'No Content',
    205: 'Reset Content',
    206: 'Partial Content',
    207: 'Multi-Status',
    208: 'Already Reported',
    214: 'Transformation Applied',
    226: 'IM Used',
    300: 'Multiple Choices',
    301: 'Moved Permanently',
    302: 'Found',
    303: 'See Other',
    304: 'Not Modified',
    305: 'Use Proxy',
    307: 'Temporary Redirect',
    308: 'Permanent Redirect',
    400: 'Bad Request',
    401: 'Unauthorized',
    402: 'Payment Required',
    403: 'Forbidden',
    404: 'Not Found',
    405: 'Method Not Allowed',
    406: 'Not Acceptable',
    407: 'Proxy Authentication Required',
    408: 'Request Timeout',
    409: 'Conflict',
    410: 'Gone',
    411: 'Length Required',
    412: 'Precondition Failed',
    413: 'Payload Too Large',
    414: 'Request-URI Too Long',
    415: 'Unsupported Media Type',
    416: 'Request Range Not Satisfiable',
    417: 'Expectation Failed',
    418: "I'm a teapot",
    419: 'Page Expired',
    420: 'Enhance Your Calm',
    421: 'Misdirected Request',
    422: 'Unprocessable Entity',
    423: 'Locked',
    424: 'Failed Dependency',
    425: 'Too Early',
    426: 'Upgrade Required',
    428: 'Precondition Required',
    429: 'Too Many Requests',
    431: 'Request Header Fields Too Large',
    444: 'No Response',
    450: 'Blocked by Windows Parental Controls',
    451: 'Unavailable For Legal Reasons',
    495: 'SSL Certificate Error',
    496: 'SSL Certificate Required',
    497: 'HTTP Request Sent to HTTPS Port',
    498: 'Token expired/invalid',
    499: 'Client Closed Request',
    500: 'Internal Server Error',
    501: 'Not Implemented',
    502: 'Bad Gateway',
    503: 'Service Unavailable',
    504: 'Gateway Timeout',
    506: 'Variant Also Negotiates',
    507: 'Insufficient Storage',
    508: 'Loop Detected',
    509: 'Bandwidth Limit Exceeded',
    510: 'Not Extended',
    511: 'Network Authentication Required',
    521: 'Web Server Is Down',
    522: 'Connection Timed Out',
    523: 'Origin Is Unreachable',
    525: 'SSL Handshake Failed',
    530: 'Site Frozen',
    599: 'Network Connect Timeout Error',
  };

  /// Get status text for a given code
  static String getStatusText(int code) => _statusTexts[code] ?? 'Unknown Status';

  /// Get category for status code (1xx, 2xx, etc.)
  String get category {
    if (statusCode < 200) return 'Informational';
    if (statusCode < 300) return 'Success';
    if (statusCode < 400) return 'Redirection';
    if (statusCode < 500) return 'Client Error';
    return 'Server Error';
  }

  @override
  String toString() => 'HttpCatImage($statusCode: $statusText)';
}
