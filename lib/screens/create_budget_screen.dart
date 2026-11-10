import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../utils/currency_utils.dart';

class CreateBudgetScreen extends StatefulWidget {
  final String currency;

  const CreateBudgetScreen({
    super.key,
    required this.currency,
  });

  @override
  State<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final List<Map<String, TextEditingController>> _categoryControllers = [];

  @override
  void dispose() {
    _nameController.dispose();
    _totalController.dispose();
    for (var cat in _categoryControllers) {
      cat['name']?.dispose();
      cat['amount']?.dispose();
    }
    super.dispose();
  }

  void _addCategoryField() {
    setState(() {
      _categoryControllers.add({
        'name': TextEditingController(),
        'amount': TextEditingController(),
      });
    });
  }

  void _removeCategoryField(int index) {
    setState(() {
      _categoryControllers[index]['name']?.dispose();
      _categoryControllers[index]['amount']?.dispose();
      _categoryControllers.removeAt(index);
    });
  }

  void _saveBudget() {
    final name = _nameController.text.trim();
    final totalText = _totalController.text.trim();

    if (name.isEmpty || totalText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter budget name and total value.')),
      );
      return;
    }

    final totalAmount = double.tryParse(totalText);
    if (totalAmount == null || totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid total budget amount.')),
      );
      return;
    }

    List<BudgetCategory> categories = [];
    double categoriesSum = 0.0;
    for (var cat in _categoryControllers) {
      final catName = cat['name']?.text.trim() ?? '';
      final catAmountText = cat['amount']?.text.trim() ?? '';
      if (catName.isNotEmpty && catAmountText.isNotEmpty) {
        final catAmount = double.tryParse(catAmountText) ?? 0.0;
        categoriesSum += catAmount;
        categories.add(BudgetCategory(name: catName, allocatedAmount: catAmount));
      }
    }

    if (categoriesSum > totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The sum of category amounts cannot exceed the total budget value!')),
      );
      return;
    }

    final budget = Budget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      totalAmount: totalAmount,
      categories: categories,
    );

    Navigator.pop(context, budget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Budget'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Budget Name',
              hintText: 'e.g. Wedding Budget, Monthly Expenses',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _totalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Total Budget Value',
              hintText: 'e.g. 10000.00',
              prefixText: getCurrencyPrefix(widget.currency),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                ),
              ),
              TextButton.icon(
                onPressed: _addCategoryField,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Category'),
                style: TextButton.styleFrom(foregroundColor: Colors.tealAccent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_categoryControllers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'No categories added yet. You can create a budget without categories, or click "Add Category" above (e.g. food, music, venue).',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ..._categoryControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final cat = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: cat['name'],
                      decoration: InputDecoration(
                        labelText: 'Category ${index + 1} Name',
                        hintText: 'e.g. Venue, Food',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: cat['amount'],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixText: getCurrencyPrefix(widget.currency),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => _removeCategoryField(index),
                    tooltip: 'Remove Category',
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saveBudget,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Create Budget',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
