import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../utils/currency_utils.dart';
import 'create_budget_screen.dart';
import 'budget_detail_screen.dart';

class BudgetsTab extends StatefulWidget {
  final List<Budget> budgets;
  final String currency;
  final VoidCallback onBudgetsChanged;

  const BudgetsTab({
    super.key,
    required this.budgets,
    required this.currency,
    required this.onBudgetsChanged,
  });

  @override
  State<BudgetsTab> createState() => _BudgetsTabState();
}

class _BudgetsTabState extends State<BudgetsTab> {
  void _openCreateBudget() async {
    final result = await Navigator.push<Budget>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateBudgetScreen(
          currency: widget.currency,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        widget.budgets.add(result);
      });
      widget.onBudgetsChanged();
    }
  }

  void _openBudgetDetail(Budget budget) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetDetailScreen(
          budget: budget,
          currency: widget.currency,
          onBudgetUpdated: () {
            setState(() {});
            widget.onBudgetsChanged();
          },
          onBudgetDeleted: () {
            setState(() {
              widget.budgets.removeWhere((b) => b.id == budget.id);
            });
            widget.onBudgetsChanged();
          },
        ),
      ),
    );
    setState(() {});
    widget.onBudgetsChanged();
  }

  void _deleteBudget(Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete "${budget.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.budgets.removeWhere((b) => b.id == budget.id);
              });
              widget.onBudgetsChanged();
              Navigator.pop(context);
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
    double totalBudgetsAmount = widget.budgets.fold(0.0, (sum, b) => sum + b.totalAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Budgets'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade800, Colors.teal.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Allocated Budgets',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(widget.currency, totalBudgetsAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.budgets.length} active budget${widget.budgets.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Budgets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.budgets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            size: 64,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No budgets created yet',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _openCreateBudget,
                            icon: const Icon(Icons.add),
                            label: const Text('Create your first budget'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: widget.budgets.length,
                      itemBuilder: (context, index) {
                        final budget = widget.budgets[index];
                        final categoriesSum = budget.categories.fold(0.0, (s, c) => s + c.allocatedAmount);
                        final unallocated = (budget.totalAmount - categoriesSum).clamp(0.0, budget.totalAmount);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _openBudgetDetail(budget),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          budget.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                                        onPressed: () => _deleteBudget(budget),
                                        tooltip: 'Delete Budget',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total: ${formatCurrency(widget.currency, budget.totalAmount)}',
                                    style: TextStyle(
                                      color: Colors.teal.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (budget.categories.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: SizedBox(
                                        height: 8,
                                        child: Row(
                                          children: [
                                            ...budget.categories.asMap().entries.map((entry) {
                                              final catIndex = entry.key;
                                              final cat = entry.value;
                                              final flex = budget.totalAmount > 0
                                                  ? ((cat.allocatedAmount / budget.totalAmount) * 1000).round()
                                                  : 0;
                                              if (flex <= 0) return const SizedBox.shrink();
                                              final color = categoryColors[catIndex % categoryColors.length];
                                              return Expanded(
                                                flex: flex,
                                                child: Container(color: color),
                                              );
                                            }),
                                            if (unallocated > 0)
                                              Expanded(
                                                flex: budget.totalAmount > 0
                                                    ? ((unallocated / budget.totalAmount) * 1000).round()
                                                    : 1000,
                                                child: Container(color: Colors.grey),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ...budget.categories.map((cat) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '• ${cat.name}',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              formatCurrency(widget.currency, cat.allocatedAmount),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    if (unallocated > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              '• Unallocated amount',
                                              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              formatCurrency(widget.currency, unallocated),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateBudget,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Budget'),
      ),
    );
  }
}
