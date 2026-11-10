import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../utils/currency_utils.dart';

class GoalsTab extends StatefulWidget {
  final List<Goal> goals;
  final String currency;
  final VoidCallback onGoalsChanged;

  const GoalsTab({
    super.key,
    required this.goals,
    required this.currency,
    required this.onGoalsChanged,
  });

  @override
  State<GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends State<GoalsTab> {
  void _createOrEditGoal({Goal? goal}) {
    final isEditing = goal != null;
    final titleController = TextEditingController(text: isEditing ? goal.title : '');
    final targetController = TextEditingController(text: isEditing ? goal.targetAmount.toString() : '');
    final savedController = TextEditingController(text: isEditing ? goal.savedAmount.toString() : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Goal' : 'Create New Goal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  hintText: 'e.g. Dream Car, New Laptop',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Target Amount',
                  hintText: 'e.g. 15000.00',
                  prefixText: getCurrencyPrefix(widget.currency),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: savedController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount Saved So Far',
                  hintText: 'e.g. 2500.00',
                  prefixText: getCurrencyPrefix(widget.currency),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final targetText = targetController.text.trim();
              final savedText = savedController.text.trim();

              if (title.isNotEmpty) {
                final target = double.tryParse(targetText) ?? 0.0;
                final saved = double.tryParse(savedText) ?? 0.0;

                setState(() {
                  if (isEditing) {
                    goal.title = title;
                    goal.targetAmount = target > 0 ? target : 1.0;
                    goal.savedAmount = saved >= 0 ? saved : 0.0;
                  } else {
                    widget.goals.add(
                      Goal(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: title,
                        targetAmount: target > 0 ? target : 1.0,
                        savedAmount: saved >= 0 ? saved : 0.0,
                      ),
                    );
                  }
                });
                widget.onGoalsChanged();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: Text(isEditing ? 'Save Changes' : 'Create Goal'),
          ),
        ],
      ),
    );
  }

  void _quickUpdateSaved(Goal goal) {
    final savedController = TextEditingController(text: goal.savedAmount.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Saved for "${goal.title}"'),
        content: TextField(
          controller: savedController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'New Saved Amount',
            prefixText: getCurrencyPrefix(widget.currency),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final savedText = savedController.text.trim();
              final saved = double.tryParse(savedText);
              if (saved != null && saved >= 0) {
                setState(() {
                  goal.savedAmount = saved;
                });
                widget.onGoalsChanged();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteGoal(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.goals.removeWhere((g) => g.id == goal.id);
              });
              widget.onGoalsChanged();
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
    double totalTarget = widget.goals.fold(0.0, (sum, g) => sum + g.targetAmount);
    double totalSaved = widget.goals.fold(0.0, (sum, g) => sum + g.savedAmount);
    double overallProgress = totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
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
                    'Goals Overview',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatCurrency(widget.currency, totalSaved),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Target: ${formatCurrency(widget.currency, totalTarget)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: overallProgress,
                      minHeight: 10,
                      backgroundColor: Colors.black26,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.tealAccent),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(overallProgress * 100).toStringAsFixed(1)}% Completed',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.goals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 64,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No goals set yet',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _createOrEditGoal(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add your first goal'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: widget.goals.length,
                      itemBuilder: (context, index) {
                        final goal = widget.goals[index];
                        final progress = goal.targetAmount > 0
                            ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0)
                            : 0.0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                                        goal.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.teal),
                                          onPressed: () => _createOrEditGoal(goal: goal),
                                          tooltip: 'Edit Goal',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                                          onPressed: () => _deleteGoal(goal),
                                          tooltip: 'Delete Goal',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Saved: ${formatCurrency(widget.currency, goal.savedAmount)}',
                                      style: TextStyle(
                                        color: Colors.teal.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'Target: ${formatCurrency(widget.currency, goal.targetAmount)}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade700),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${(progress * 100).toStringAsFixed(1)}% reached',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _quickUpdateSaved(goal),
                                      icon: const Icon(Icons.update, size: 16),
                                      label: const Text('Update Saved'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.teal.shade700,
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(50, 30),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
        onPressed: () => _createOrEditGoal(),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Goal'),
      ),
    );
  }
}
