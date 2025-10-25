import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense_model.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../constants/app_constants.dart';
import '../../widgets/expense_list_item.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _searchController = TextEditingController();
  ExpenseCategory? _selectedCategory;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<ExpenseViewModel>(
        builder: (context, expenseViewModel, child) {
          if (expenseViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final expenses = expenseViewModel.filteredExpenses;

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search expenses...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              expenseViewModel.setSearchQuery('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  onChanged: (value) {
                    expenseViewModel.setSearchQuery(value);
                  },
                ),
              ),

              // Filter Chips
              if (_selectedCategory != null || _selectedDate != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding),
                  child: Row(
                    children: [
                      if (_selectedCategory != null)
                        Chip(
                          label: Text(_selectedCategory!.categoryDisplayName),
                          onDeleted: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                            expenseViewModel.setCategoryFilter(null);
                          },
                        ),
                      if (_selectedDate != null)
                        Chip(
                          label: Text(
                            '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          ),
                          onDeleted: () {
                            setState(() {
                              _selectedDate = null;
                            });
                            expenseViewModel.setDateFilter(null);
                          },
                        ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = null;
                            _selectedDate = null;
                          });
                          expenseViewModel.clearFilters();
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                ),

              // Expenses List
              Expanded(
                child: expenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No expenses found',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first expense to get started',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.all(AppConstants.defaultPadding),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ExpenseListItem(
                              expense: expense,
                              onTap: () => _showExpenseDetails(expense),
                              onEdit: () => _editExpense(expense),
                              onDelete: () => _deleteExpense(expense),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Expenses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Filter
            DropdownButtonFormField<ExpenseCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: [
                const DropdownMenuItem<ExpenseCategory>(
                  value: null,
                  child: Text('All Categories'),
                ),
                ...ExpenseCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Text(category.icon),
                        const SizedBox(width: 8),
                        Text(category.categoryDisplayName),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Date Filter
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'All Dates',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final expenseViewModel =
                  Provider.of<ExpenseViewModel>(context, listen: false);
              expenseViewModel.setCategoryFilter(_selectedCategory);
              expenseViewModel.setDateFilter(_selectedDate);
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showExpenseDetails(ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.description),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Amount',
                '${AppConstants.defaultCurrency}${expense.amount.toStringAsFixed(2)}'),
            _buildDetailRow('Category',
                '${expense.categoryIcon} ${expense.categoryDisplayName}'),
            _buildDetailRow('Date',
                '${expense.date.day}/${expense.date.month}/${expense.date.year}'),
            if (expense.isRecurring)
              _buildDetailRow(
                  'Recurring', expense.recurringType?.toUpperCase() ?? 'Yes'),
            if (expense.imageUrl != null)
              _buildDetailRow('Receipt', 'Available'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editExpense(expense);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _editExpense(ExpenseModel expense) {
    // TODO: Navigate to edit expense screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon!'),
      ),
    );
  }

  void _deleteExpense(ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content:
            Text('Are you sure you want to delete "${expense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final expenseViewModel =
                  Provider.of<ExpenseViewModel>(context, listen: false);
              await expenseViewModel.deleteExpense(expense.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
