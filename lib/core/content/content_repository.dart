import 'dart:convert';

import 'package:http/http.dart' as http;

const String _kContentApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

class ContentRepository {
  ContentRepository._();

  static final ContentRepository instance = ContentRepository._();

  final http.Client _client = http.Client();
  Map<String, List<Map<String, dynamic>>> _guidesByLocale = {};
  Map<String, List<Map<String, dynamic>>> _tasksByLocale = {};
  Map<String, List<Map<String, dynamic>>> _placesByLocale = {};
  Map<String, List<Map<String, dynamic>>> _campaignsByLocale = {};
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final uri = Uri.parse('$_kContentApiBaseUrl/content/snapshot');
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) return;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return;
      _guidesByLocale = _groupByLocale(decoded['guides']);
      _tasksByLocale = _groupByLocale(decoded['tasks']);
      _placesByLocale = _groupByLocale(decoded['places']);
      _campaignsByLocale = _groupByLocale(decoded['campaigns']);
    } catch (_) {
      // Fall back to bundled content if the backend is unavailable.
    }
  }

  List<Map<String, dynamic>>? guides(String locale) => _guidesByLocale[locale];
  List<Map<String, dynamic>>? tasks(String locale) => _tasksByLocale[locale];
  List<Map<String, dynamic>>? places(String locale) => _placesByLocale[locale];
  List<Map<String, dynamic>>? campaigns(String locale) => _campaignsByLocale[locale];

  Map<String, List<Map<String, dynamic>>> _groupByLocale(Object? value) {
    final result = <String, List<Map<String, dynamic>>>{};
    if (value is! List) return result;
    for (final item in value) {
      if (item is! Map<String, dynamic>) continue;
      final locale = (item['locale'] ?? 'en').toString();
      result.putIfAbsent(locale, () => <Map<String, dynamic>>[]).add(item);
    }
    return result;
  }
}
