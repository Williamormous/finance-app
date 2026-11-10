import 'package:flutter/material.dart';

String formatCurrency(String currency, double amount) {
  final hasLetters = currency.contains(RegExp(r'[A-Za-z]'));
  final separator = hasLetters ? ' ' : '';
  return '$currency$separator${amount.toStringAsFixed(2)}';
}

String formatSignedCurrency(String currency, double amount, bool isGain) {
  final sign = isGain ? '+' : '-';
  final hasLetters = currency.contains(RegExp(r'[A-Za-z]'));
  final separator = hasLetters ? ' ' : '';
  return '$sign$currency$separator${amount.toStringAsFixed(2)}';
}

String getCurrencyPrefix(String currency) {
  final hasLetters = currency.contains(RegExp(r'[A-Za-z]'));
  return hasLetters ? '$currency ' : currency;
}

const List<Color> categoryColors = [
  Colors.tealAccent,
  Colors.amberAccent,
  Colors.lightBlueAccent,
  Colors.pinkAccent,
  Colors.orangeAccent,
  Colors.purpleAccent,
  Colors.limeAccent,
  Colors.cyanAccent,
];
