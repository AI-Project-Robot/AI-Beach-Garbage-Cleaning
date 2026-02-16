import 'package:flutter/material.dart';

import 'api_client.dart';
import 'distances_page.dart';

class ApiHomePage extends StatefulWidget {
  const ApiHomePage({super.key});

  @override
  State<ApiHomePage> createState() => _ApiHomePageState();
}

class _ApiHomePageState extends State<ApiHomePage> {
  final _ipAddressController = TextEditingController(text: 'localhost');
  final _portController = TextEditingController(text: '5000');
  final _basePathController = TextEditingController(text: '/api');
  bool _loading = false;

  String _buildBaseUrl() {
    final ip = _ipAddressController.text.trim();
    final port = _portController.text.trim();
    final basePath = _basePathController.text.trim();

    final normalizedPath = basePath.isEmpty
        ? ''
        : (basePath.startsWith('/') ? basePath : '/$basePath');

    final host = ip.isEmpty ? 'localhost' : ip;
    final portSegment = port.isEmpty ? '' : ':$port';

    return 'http://$host$portSegment$normalizedPath';
  }

  @override
  void dispose() {
    _ipAddressController.dispose();
    _portController.dispose();
    _basePathController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<dynamic> Function() action) async {
    setState(() {
      _loading = true;
    });

    try {
      await action();
    } catch (e) {
      debugPrint('Signal action failed: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<bool> _canConnect(String baseUrl) async {
    try {
      final client = SignalApiClient(baseUrl: baseUrl);
      await client.getAllSignals();
      return true;
    } catch (_) {
      return false;
    }
  }

  String? _validateInputs() {
    final ip = _ipAddressController.text.trim();
    final port = _portController.text.trim();
    final basePath = _basePathController.text.trim();

    if (ip.isEmpty) {
      return 'IP Address is required';
    }

    if (port.isNotEmpty) {
      final parsedPort = int.tryParse(port);
      if (parsedPort == null || parsedPort <= 0 || parsedPort > 65535) {
        return 'Port must be a number between 1 and 65535';
      }
    }

    if (basePath.isNotEmpty && !basePath.startsWith('/')) {
      return 'Base Path must start with /';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('API Settings'),
        _inputField(
          controller: _ipAddressController,
          label: 'IP Address',
          helper: 'Example: 192.168.1.10',
        ),
        _inputField(
          controller: _portController,
          label: 'Port',
          keyboardType: TextInputType.number,
        ),
        _inputField(
          controller: _basePathController,
          label: 'Base Path',
          helper: 'Example: /api',
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Base URL: ${_buildBaseUrl()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 16),
        _actionButton('Save', () async {
          final error = _validateInputs();
          if (error != null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
            return;
          }
          final baseUrl = _buildBaseUrl();
          await _run(() async {
            final ok = await _canConnect(baseUrl);
            if (!mounted) return;
            if (!ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API not reachable')),
              );
              return;
            }
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DistancesPage(baseUrl: baseUrl),
              ),
            );
          });
        }),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluvyn Beach Cleaning Robot'),
      ),
      body: Stack(
        children: [
          content,
          if (_loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    String? helper,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _actionButton(String label, Future<void> Function() onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.black,
      ),
      onPressed: _loading ? null : () => onPressed(),
      child: Text(label),
    );
  }
}
