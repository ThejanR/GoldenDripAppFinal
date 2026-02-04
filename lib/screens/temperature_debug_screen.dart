import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/temperature_provider.dart';

class TemperatureDebugScreen extends StatefulWidget {
  const TemperatureDebugScreen({super.key});

  @override
  State<TemperatureDebugScreen> createState() => _TemperatureDebugScreenState();
}

class _TemperatureDebugScreenState extends State<TemperatureDebugScreen> {
  late double _temperatureValue;
  final TextEditingController _temperatureController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _temperatureValue = 22.0;
    _temperatureController.text = '22.0';
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    super.dispose();
  }

  void _updateTemperature(double value) {
    setState(() {
      _temperatureValue = value;
      _temperatureController.text = value.toStringAsFixed(1);
    });

    // Update the temperature provider
    Provider.of<TemperatureProvider>(context, listen: false)
        .simulateEmulatorTemperatureChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Debug'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Temperature:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Consumer<TemperatureProvider>(
                      builder: (context, temperatureProvider, child) {
                        return Text(
                          '${temperatureProvider.currentTemperature?.toStringAsFixed(1) ?? 'N/A'}°C',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Consumer<TemperatureProvider>(
                      builder: (context, temperatureProvider, child) {
                        return Text(
                          temperatureProvider.temperatureRecommendation,
                          style: const TextStyle(fontSize: 16),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Simulate Emulator Temperature:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _temperatureValue,
              min: 0,
              max: 40,
              divisions: 80,
              label: '${_temperatureValue.toStringAsFixed(1)}°C',
              onChanged: (double value) {
                _updateTemperature(value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _temperatureController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Temperature (°C)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        double? temp = double.tryParse(value);
                        if (temp != null && temp >= 0 && temp <= 40) {
                          _updateTemperature(temp);
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_temperatureController.text.isNotEmpty) {
                      double? temp =
                          double.tryParse(_temperatureController.text);
                      if (temp != null && temp >= 0 && temp <= 40) {
                        _updateTemperature(temp);
                      }
                    }
                  },
                  child: const Text('Set'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick Presets:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _updateTemperature(10.0),
                  child: const Text('10°C\n(Cold)'),
                ),
                ElevatedButton(
                  onPressed: () => _updateTemperature(18.0),
                  child: const Text('18°C\n(Cool)'),
                ),
                ElevatedButton(
                  onPressed: () => _updateTemperature(22.0),
                  child: const Text('22°C\n(Mild)'),
                ),
                ElevatedButton(
                  onPressed: () => _updateTemperature(28.0),
                  child: const Text('28°C\n(Warm)'),
                ),
                ElevatedButton(
                  onPressed: () => _updateTemperature(35.0),
                  child: const Text('35°C\n(Hot)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
