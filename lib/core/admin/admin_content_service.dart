import 'dart:convert';

import 'package:http/http.dart' as http;

const String _kAdminApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

class AdminContentService {
  AdminContentService._();

  static final AdminContentService instance = AdminContentService._();

  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> fetchSnapshot(String adminKey) async {
    return _request(
      adminKey: adminKey,
      method: 'GET',
      path: '/content/snapshot',
    );
  }

  Future<List<Map<String, dynamic>>> listGuides(String adminKey) async {
    final data = await _request(adminKey: adminKey, method: 'GET', path: '/admin/guides');
    return _asList(data);
  }

  Future<List<Map<String, dynamic>>> listTasks(String adminKey) async {
    final data = await _request(adminKey: adminKey, method: 'GET', path: '/admin/tasks');
    return _asList(data);
  }

  Future<List<Map<String, dynamic>>> listPlaces(String adminKey) async {
    final data = await _request(adminKey: adminKey, method: 'GET', path: '/admin/places');
    return _asList(data);
  }

  Future<List<Map<String, dynamic>>> listCampaigns(String adminKey) async {
    final data = await _request(adminKey: adminKey, method: 'GET', path: '/admin/notifications');
    return _asList(data);
  }

  Future<void> createGuide(String adminKey, Map<String, dynamic> payload) async {
    await _request(adminKey: adminKey, method: 'POST', path: '/admin/guides', body: payload);
  }

  Future<void> createTask(String adminKey, Map<String, dynamic> payload) async {
    await _request(adminKey: adminKey, method: 'POST', path: '/admin/tasks', body: payload);
  }

  Future<void> createPlace(String adminKey, Map<String, dynamic> payload) async {
    await _request(adminKey: adminKey, method: 'POST', path: '/admin/places', body: payload);
  }

  Future<void> createCampaign(String adminKey, Map<String, dynamic> payload) async {
    await _request(adminKey: adminKey, method: 'POST', path: '/admin/notifications', body: payload);
  }

  Future<void> deleteItem(String adminKey, String path) async {
    await _request(adminKey: adminKey, method: 'DELETE', path: path);
  }

  Future<void> sendCampaign(String adminKey, String id) async {
    await _request(
      adminKey: adminKey,
      method: 'POST',
      path: '/admin/notifications/$id/send',
    );
  }

  Future<Map<String, dynamic>> _request({
    required String adminKey,
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_kAdminApiBaseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-admin-key': adminKey,
    };
    late final http.Response response;
    if (method == 'GET') {
      response = await _client.get(uri, headers: headers);
    } else if (method == 'PATCH') {
      response = await _client.patch(uri, headers: headers, body: jsonEncode(body ?? {}));
    } else if (method == 'DELETE') {
      response = await _client.delete(uri, headers: headers);
    } else {
      response = await _client.post(uri, headers: headers, body: jsonEncode(body ?? {}));
    }
    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString() ?? decoded['error']?.toString() ?? 'Request failed'
          : 'Request failed';
      throw Exception(message);
    }
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{'data': decoded};
  }

  List<Map<String, dynamic>> _asList(Map<String, dynamic> data) {
    final values = data['data'] ?? data['items'] ?? data['results'] ?? data;
    if (values is List) {
      return values.whereType<Map<String, dynamic>>().toList();
    }
    if (values is Map<String, dynamic>) {
      return [values];
    }
    return const [];
  }
}
