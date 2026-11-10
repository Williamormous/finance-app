import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/goal.dart';
import '../services/storage_service.dart';
import 'accounts_dashboard_tab.dart';
import 'goals_tab.dart';
import 'settings_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;
  final ThemeMode currentThemeMode;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const MainNavigationScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  bool _isLoading = true;

  List<Account> _accounts = [];
  List<Goal> _goals = [];
  String _currency = '\$';

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final data = await StorageService.loadData();
    if (mounted) {
      setState(() {
        _accounts = List<Account>.from(data['accounts']!);
        _goals = List<Goal>.from(data['goals']!);
        _currency = data['currency'] as String? ?? '\$';
        _isLoading = false;
      });
    }
  }

  Future<void> _persistData() async {
    await StorageService.saveData(_accounts, _goals, _currency);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.tealAccent,
          ),
        ),
      );
    }

    final screens = [
      AccountsDashboardTab(
        accounts: _accounts,
        currency: _currency,
        onAccountsChanged: () {
          setState(() {});
          _persistData();
        },
      ),
      GoalsTab(
        goals: _goals,
        currency: _currency,
        onGoalsChanged: () {
          setState(() {});
          _persistData();
        },
      ),
      SettingsTab(
        isDarkMode: widget.currentThemeMode == ThemeMode.dark,
        onThemeChanged: widget.onThemeChanged,
        currency: _currency,
        onCurrencyChanged: (newCurrency) {
          setState(() {
            _currency = newCurrency;
          });
          _persistData();
        },
      ),
    ];

    return Scaffold(
      body: screens[widget.currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.currentIndex,
        onDestinationSelected: widget.onTabChanged,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'My Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'My Goals',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
