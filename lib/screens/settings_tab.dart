import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final String currency;
  final ValueChanged<String> onCurrencyChanged;

  const SettingsTab({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.currency,
    required this.onCurrencyChanged,
  });

  static const List<Map<String, String>> _currencies = [
    {'symbol': '\$', 'name': 'USD (\$)'},
    {'symbol': '€', 'name': 'EUR (€)'},
    {'symbol': '£', 'name': 'GBP (£)'},
    {'symbol': '¥', 'name': 'JPY/CNY (¥)'},
    {'symbol': '₹', 'name': 'INR (₹)'},
    {'symbol': 'AED', 'name': 'AED (AED)'},
    {'symbol': 'CHF', 'name': 'CHF (CHF)'},
    {'symbol': 'CA\$', 'name': 'CAD (CA\$)'},
    {'symbol': 'AU\$', 'name': 'AUD (AU\$)'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              secondary: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Colors.teal.shade700,
              ),
              title: const Text(
                'Dark Theme',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(isDarkMode ? 'Currently using dark mode' : 'Currently using light mode'),
              value: isDarkMode,
              onChanged: onThemeChanged,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Preferences',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                Icons.attach_money,
                color: Colors.teal.shade700,
              ),
              title: const Text(
                'Currency',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Selected: $currency'),
              trailing: DropdownButton<String>(
                value: _currencies.any((c) => c['symbol'] == currency) ? currency : '\$',
                underline: const SizedBox(),
                items: _currencies.map((curr) {
                  return DropdownMenuItem<String>(
                    value: curr['symbol'],
                    child: Text(curr['name']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    onCurrencyChanged(val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
