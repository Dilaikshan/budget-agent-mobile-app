import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Info'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LEDGER INVARIANTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey)),
                  const SizedBox(height: 12),
                  _buildRow('Base Currency', config.defaultCurrency),
                  _buildRow('Currency Exponent', '${config.currencyExponent} minor units'),
                  _buildRow('Default TimeZone', config.defaultTimeZone),
                  _buildRow('Backend Gateway', config.backendBaseUrl),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SECURITY & PRIVACY BOUNDARY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Color(0xFF10B981))),
                  const SizedBox(height: 8),
                  const Text(
                    'Per AGENTS.md:\n• Every financial mutation requires explicit user confirmation of the exact payload.\n• AI never executes financial tools.\n• Confidence never grants mutation permission.\n• No provider secrets are packaged in Flutter builds.',
                    style: TextStyle(fontSize: 13, height: 1.4, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.between,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 13)),
        ],
      ),
    );
  }
}
