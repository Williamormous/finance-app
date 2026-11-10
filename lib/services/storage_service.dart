import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';
import '../models/goal.dart';
import '../models/budget.dart';

class StorageService {
  static const String _accountsKey = 'saved_accounts_v2';
  static const String _goalsKey = 'saved_goals_v2';
  static const String _budgetsKey = 'saved_budgets_v1';
  static const String _currencyKey = 'app_currency_v1';
  static const String themeKey = 'app_is_dark_v1';

  static Future<void> saveData(
    List<Account> accounts,
    List<Goal> goals,
    List<Budget> budgets,
    String currency,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsJson = jsonEncode(accounts.map((a) => a.toJson()).toList());
      final goalsJson = jsonEncode(goals.map((g) => g.toJson()).toList());
      final budgetsJson = jsonEncode(budgets.map((b) => b.toJson()).toList());
      await prefs.setString(_accountsKey, accountsJson);
      await prefs.setString(_goalsKey, goalsJson);
      await prefs.setString(_budgetsKey, budgetsJson);
      await prefs.setString(_currencyKey, currency);
      if (kDebugMode) {
        print('StorageService: Data and settings successfully saved.');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('StorageService error saving data: $e\n$stackTrace');
      }
    }
  }

  static Future<Map<String, dynamic>> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsString = prefs.getString(_accountsKey);
      final goalsString = prefs.getString(_goalsKey);
      final budgetsString = prefs.getString(_budgetsKey);
      final currency = prefs.getString(_currencyKey) ?? '\$';
      final isDark = prefs.getBool(themeKey) ?? true;

      List<Account> accounts = [
        Account(id: '1', name: 'Main Wallet', balance: 0.00, transactions: [])
      ];
      List<Goal> goals = [];
      List<Budget> budgets = [];

      if (accountsString != null && accountsString.isNotEmpty) {
        final List decoded = jsonDecode(accountsString);
        accounts = decoded.map((e) => Account.fromJson(e)).toList();
      }

      if (goalsString != null && goalsString.isNotEmpty) {
        final List decoded = jsonDecode(goalsString);
        goals = decoded.map((e) => Goal.fromJson(e)).toList();
      }

      if (budgetsString != null && budgetsString.isNotEmpty) {
        final List decoded = jsonDecode(budgetsString);
        budgets = decoded.map((e) => Budget.fromJson(e)).toList();
      }

      if (kDebugMode) {
        print('StorageService: Loaded ${accounts.length} accounts, ${goals.length} goals, ${budgets.length} budgets, currency: $currency, isDark: $isDark.');
      }

      return {
        'accounts': accounts,
        'goals': goals,
        'budgets': budgets,
        'currency': currency,
        'isDark': isDark,
      };
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('StorageService error loading data: $e\n$stackTrace');
      }
      return {
        'accounts': [Account(id: '1', name: 'Main Wallet', balance: 0.00, transactions: [])],
        'goals': <Goal>[],
        'budgets': <Budget>[],
        'currency': '\$',
        'isDark': true,
      };
    }
  }
}
