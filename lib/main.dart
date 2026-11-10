import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const FinanceTrackerApp());
}

class FinanceTrackerApp extends StatefulWidget {
  const FinanceTrackerApp({super.key});

  @override
  State<FinanceTrackerApp> createState() => _FinanceTrackerAppState();
}

class _FinanceTrackerAppState extends State<FinanceTrackerApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  int _currentIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadThemeSetting();
  }

  Future<void> _loadThemeSetting() async {
    final data = await StorageService.loadData();
    final isDark = data['isDark'] as bool? ?? true;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _isInitialized = true;
    });
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    StorageService.loadData().then((data) {
      StorageService.saveData(
        data['accounts'],
        data['goals'],
        data['budgets'],
        data['currency'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Colors.tealAccent),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
          surface: const Color(0xFFF0F4F3),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F4F3),
        cardColor: const Color(0xFFE2EBE8),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade800,
          foregroundColor: Colors.white,
          scrolledUnderElevation: 0.0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade900,
          foregroundColor: Colors.white,
          scrolledUnderElevation: 0.0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: MainNavigationScreen(
        onThemeChanged: _toggleTheme,
        currentThemeMode: _themeMode,
        currentIndex: _currentIndex,
        onTabChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
