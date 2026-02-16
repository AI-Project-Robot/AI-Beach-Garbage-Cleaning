import 'package:flutter/material.dart';
import 'api_client.dart'; 

class DistancesPage extends StatefulWidget {
  const DistancesPage({super.key, required this.baseUrl});

  final String baseUrl;

  @override
  State<DistancesPage> createState() => _DistancesPageState();
}

class _DistancesPageState extends State<DistancesPage> {
  // Controllers for the manual input fields
  final _t1DistanceController = TextEditingController();
  final _t2DistanceController = TextEditingController();
  final _actualDistanceController = TextEditingController();

  bool _loading = false;

  // Create the API client using the baseUrl passed to the widget
  SignalApiClient get _client => SignalApiClient(baseUrl: widget.baseUrl);

  @override
  void dispose() {
    _t1DistanceController.dispose();
    _t2DistanceController.dispose();
    _actualDistanceController.dispose();
    super.dispose();
  }

  // Helper to run async actions with loading state
  Future<void> _run(Future<dynamic> Function() action) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
    });

    try {
      await action();
    } catch (e) {
      debugPrint('Signal action failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  double? _parseDouble(TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- Section 1: Manual Data Collection ---
        _sectionTitle('Training Data Collection'),
        const Text(
          "Use this section when gathering dataset points with measured distances.",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 10),
        _inputField(
          controller: _t1DistanceController,
          label: 'T1 Distance (m)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        _inputField(
          controller: _t2DistanceController,
          label: 'T2 Distance (m)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        _inputField(
          controller: _actualDistanceController,
          label: 'Actual Distance (m)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 10),
        
        // Button 1: Init Signal (Manual Data)
        _actionButton(
          label: 'Init Signal (Save Data)', 
          color: Colors.lightBlue,
          textColor: Colors.black,
          onPressed: () async {
            final t1 = _parseDouble(_t1DistanceController);
            final t2 = _parseDouble(_t2DistanceController);
            final actual = _parseDouble(_actualDistanceController);

            if (t1 == null || t2 == null || actual == null) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All distances are required for data collection')),
              );
              return;
            }

            await _run(() async {
              final id = await _client.initSignal(
                t1Distance: t1,
                t2Distance: t2,
                actualDistance: actual,
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Signal initialized: $id'),
                  backgroundColor: Colors.blue,
                ),
              );
            });
          }
        ),

        const Divider(height: 40, thickness: 2),

        // --- Section 2: Quick Trigger ---
        _sectionTitle('Robot Operation'),
        const Text(
          "Use this to just start the robot without saving distance data.",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 15),

        // Button 2: Trigger Signal (Automatic/No Data)
        SizedBox(
          height: 50, // Make this button bigger
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange, // Distinct color
              foregroundColor: Colors.white,
            ),
            onPressed: _loading ? null : () async {
               await _run(() async {
                final id = await _client.triggerSignal();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Signal TRIGGERED! ID: $id'),
                    backgroundColor: Colors.green,
                  ),
                );
              });
            },
            icon: const Icon(Icons.touch_app),
            label: const Text(
              'TRIGGER SIGNAL (Start Robot)', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signal Control'),
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

  Widget _actionButton({
    required String label, 
    required Future<void> Function() onPressed,
    Color? color,
    Color? textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.blue,
          foregroundColor: textColor ?? Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: _loading ? null : () => onPressed(),
        child: Text(label),
      ),
    );
  }
}