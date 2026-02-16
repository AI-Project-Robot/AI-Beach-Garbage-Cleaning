import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:signal_distance_app/api_client.dart';

void main() {
  test('getAllSignals returns list', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/api/signals') {
        return http.Response(jsonEncode([{'signal_id': 1}]), 200);
      }
      return http.Response('Not found', 404);
    });

    final api = SignalApiClient(baseUrl: 'http://localhost:5000/api', client: client);
    final result = await api.getAllSignals();

    expect(result, isA<List>());
    expect(result.first['signal_id'], 1);
  });

  test('getSignal returns map', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/api/signals/5') {
        return http.Response(jsonEncode({'signal_id': 5}), 200);
      }
      return http.Response('Not found', 404);
    });

    final api = SignalApiClient(baseUrl: 'http://localhost:5000/api', client: client);
    final result = await api.getSignal(5);

    expect(result['signal_id'], 5);
  });

  test('initSignal returns id', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/api/init-signal') {
        return http.Response('3', 201);
      }
      return http.Response('Not found', 404);
    });

    final api = SignalApiClient(baseUrl: 'http://localhost:5000/api', client: client);
    final result = await api.initSignal(t1Distance: 1.0, t2Distance: 2.0, actualDistance: 1.5);

    expect(result, 3);
  });

  test('updateSignal returns true', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/api/signals/7') {
        return http.Response('true', 200);
      }
      return http.Response('Not found', 404);
    });

    final api = SignalApiClient(baseUrl: 'http://localhost:5000/api', client: client);
    final result = await api.updateSignal(7, {'t1_distance': 2.5});

    expect(result, isTrue);
  });

  test('deleteSignal returns true', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/api/signals/9') {
        return http.Response(jsonEncode({'message': 'deleted'}), 200);
      }
      return http.Response('Not found', 404);
    });

    final api = SignalApiClient(baseUrl: 'http://localhost:5000/api', client: client);
    final result = await api.deleteSignal(9);

    expect(result, isTrue);
  });
}
