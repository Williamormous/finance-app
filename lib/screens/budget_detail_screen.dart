import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../utils/currency_utils.dart';

class BudgetDetailScreen extends StatefulWidget {
  final Budget budget;
  final String currency;
  final VoidCallback onBudgetUpdated;
  final VoidCallback onBudgetDeleted;

  const BudgetDetailScreen({
    super.key,
    required this.budget,
    required this.currency,
    required this.onBudgetUpdated,
    required this.onBudgetDeleted,
  });

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _totalController;

  static const List<Color> _categoryColors = [
    Colors.tealAccent,
    Colors.amberAccent,
    Colors.lightBlueAccent,
    Colors.pinkAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.limeAccent,
    Colors.cyanAccent,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.budget.name);
    _totalController = TextEditingController(text: widget.budget.totalAmount.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  double get _categoriesSum {
    return widget.budget.categories.fold(0.0, (sum, c) => sum + c.allocatedAmount);
  }

  void _updateBudgetDetails() {
    final name = _nameController.text.trim();
    final totalText = _totalController.text.trim();

    if (name.isEmpty || totalText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget name and total cannot be empty.')),
      );
      return;
    }

    final newTotal = double.tryParse(totalText);
    if (newTotal == null || newTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid total budget amount.')),
      );
      return;
    }

    if (_categoriesSum > newTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total budget cannot be less than the sum of existing categories.')),
      );
      return;
    }

    setState(() {
      widget.budget.name = name;
      widget.budget.totalAmount = newTotal;
    });
    widget.onBudgetUpdated();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget updated successfully.')),
    );
  }

  void _showAddOrEditCategoryDialog({BudgetCategory? categoryToEdit, int? editIndex}) {
    final isEditing = categoryToEdit != null;
    final catNameController = TextEditingController(text: isEditing ? categoryToEdit.name : '');
    final catAmountController = TextEditingController(text: isEditing ? categoryToEdit.allocatedAmount.toString() : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: catNameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g. Venue, Food, Music',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: catAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Allocated Amount',
                prefixText: getCurrencyPrefix(widget.currency),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = catNameController.text.trim();
              final amountText = catAmountController.text.trim();

              if (name.isNotEmpty && amountText.isNotEmpty) {
                final amount = double.tryParse(amountText);
                if (amount != null && amount > 0) {
                  double currentSumWithoutThis = _categoriesSum;
                  if (isEditing) {
                    currentSumWithoutThis -= categoryToEdit.allocatedAmount;
                  }

                  if (currentSumWithoutThis + amount > widget.budget.totalAmount) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Category amount exceeds total available budget!')),
                    );
                    return;
                  }

                  setState(() {
                    if (isEditing && editIndex != null) {
                      widget.budget.categories[editIndex].name = name;
                      widget.budget.categories[editIndex].allocatedAmount = amount;
                    } else {
                      widget.budget.categories.add(
                        BudgetCategory(name: name, allocatedAmount: amount),
                      );
                    }
                  });
                  widget.onBudgetUpdated();
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(int index) {
    setState(() {
      widget.budget.categories.removeAt(index);
    });
    widget.onBudgetUpdated();
  }

  void _confirmDeleteBudget() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete "${widget.budget.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              widget.onBudgetDeleted();
              Navigator.pop(context); // return to budgets list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unallocatedAmount = (widget.budget.totalAmount - _categoriesSum).clamp(0.0, widget.budget.totalAmount);
    
    // Prepare values and colors for Pie Chart
    List<double> pieValues = [];
    List<Color> pieColors = [];
    for (int i = 0; i < widget.budget.categories.length; i++) {
      pieValues.add(widget.budget.categories[i].allocatedAmount);
      pieColors.add(_categoryColors[i % _categoryColors.length]);
    }
    if (unallocatedAmount > 0) {
      pieValues.add(unallocatedAmount);
      pieColors.add(Colors.grey);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDeleteBudget,
            tooltip: 'Delete Budget',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Edit Budget General Details Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Budget Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Budget Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _totalController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Total Budget Value',
                      prefixText: getCurrencyPrefix(widget.currency),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _updateBudgetDetails,
                      icon: const Icon(Icons.save, size: 16),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Categories Breakdown Header & Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories & Allocation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddOrEditCategoryDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Category'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pie Chart representation if categories exist
          if (widget.budget.categories.isNotEmpty) ...[
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: PieChartPainter(
                    values: pieValues,
                    colors: pieColors,
                    total: widget.budget.totalAmount,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Categories List + Unallocated Amount
          if (widget.budget.categories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'No categories added yet. Click "Add Category" above to allocate funds.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else ...[
            ...widget.budget.categories.asMap().entries.map((entry) {
              final index = entry.key;
              final cat = entry.value;
              final color = _categoryColors[index % _categoryColors.length];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Icon(Icons.circle, color: color, size: 16),
                  ),
                  title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatCurrency(widget.currency, cat.allocatedAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.teal),
                        onPressed: () => _showAddOrEditCategoryDialog(
                          categoryToEdit: cat,
                          editIndex: index,
                        ),
                        tooltip: 'Edit Category',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                        onPressed: () => _deleteCategory(index),
                        tooltip: 'Delete Category',
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          // Unallocated amount row (always grey, shown whenever there are categories)
          if (widget.budget.categories.isNotEmpty)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.grey.withValues(alpha: 0.1),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  child: const Icon(Icons.circle, color: Colors.grey, size: 16),
                ),
                title: const Text(
                  'Unallocated amount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                trailing: Text(
                  formatCurrency(widget.currency, unallocatedAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double total;

  PieChartPainter({
    required this.values,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0 || values.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black38
      ..strokeWidth = 1.5;

    for (int i = 0; i < values.length; i++) {
      if (values[i] <= 0) continue;
      final sweepAngle = (values[i] / total) * 2 * math.pi;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      canvas.drawArc(rect, startAngle, sweepAngle, true, borderPaint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors || oldDelegate.total != total;
  }
}
