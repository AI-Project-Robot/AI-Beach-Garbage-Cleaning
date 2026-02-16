import 'dart:convert';
import 'package:http/http.dart' as http;

class SignalApiClient {
  // Constructor
  SignalApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  // Helper to build URIs
  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  // --- GET ALL SIGNALS ---
  Future<List<dynamic>> getAllSignals() async {
    final response = await _client.get(_uri('/signals'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load signals (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded;
    }
    throw Exception('Unexpected response format');
  }

  // --- GET SINGLE SIGNAL ---
  Future<Map<String, dynamic>> getSignal(int signalId) async {
    final response = await _client.get(_uri('/signals/$signalId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load signal (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('Unexpected response format');
  }

  // --- INIT SIGNAL (With Distances) ---
  Future<int> initSignal({
    required double t1Distance,
    required double t2Distance,
    required double actualDistance,
  }) async {
    final response = await _client.post(
      _uri('/init-signal'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        't1_distance': t1Distance,
        't2_distance': t2Distance,
        'actual_distance': actualDistance,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to init signal (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is int) {
      return decoded;
    }
    if (decoded is num) {
      return decoded.toInt();
    }
    throw Exception('Unexpected response format');
  }

  // --- TRIGGER SIGNAL (New Feature) ---
  // This calls the new endpoint that sets distances to -1.0
  Future<int> triggerSignal() async {
    final response = await _client.post(
      _uri('/trigger-signal'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to trigger signal: ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is int) {
      return decoded;
    }
    if (decoded is num) {
      return decoded.toInt();
    }
    throw Exception('Unexpected response format: $decoded');
  }

  // --- EMIT SIGNAL ---
  Future<int> emitSignal({required String receiver}) async {
    final response = await _client.post(
      _uri('/emit-signal'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'receiver': receiver}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to emit signal (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is int) {
      return decoded;
    }
    if (decoded is num) {
      return decoded.toInt();
    }
    throw Exception('Unexpected response format');
  }

  // --- RECEIVE SIGNAL ---
  Future<bool> receiveSignal({
    required int signalId,
    required String receiver,
  }) async {
    final response = await _client.put(
      _uri('/receive-signal/$signalId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'receiver': receiver}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to receive signal (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is bool) {
      return decoded;
    }
    throw Exception('Unexpected response format');
  }

  // --- UPDATE SIGNAL ---
  Future<bool> updateSignal(int signalId, Map<String, dynamic> payload) async {
    final response = await _client.put(
      _uri('/signals/$signalId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update signal (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is bool) {
      return decoded;
    }
    throw Exception('Unexpected response format');
  }

  // --- DELETE SIGNAL ---
  Future<bool> deleteSignal(int signalId) async {
    final response = await _client.delete(_uri('/signals/$signalId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete signal (${response.statusCode})');
    }
    return true;
  }
}