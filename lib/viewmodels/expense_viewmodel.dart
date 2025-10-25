import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../models/budget_model.dart';
import '../services/firebase_service.dart';
import '../services/ocr_service.dart';
import 'dart:io';

class ExpenseViewModel extends ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> _filteredExpenses = [];
  BudgetModel? _currentBudget;
  Map<String, double> _categorySpending = {};
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  ExpenseCategory? _selectedCategory;
  DateTime? _selectedDate;

  // Getters
  List<ExpenseModel> get expenses => _expenses;
  List<ExpenseModel> get filteredExpenses => _filteredExpenses;
  BudgetModel? get currentBudget => _currentBudget;
  Map<String, double> get categorySpending => _categorySpending;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  ExpenseCategory? get selectedCategory => _selectedCategory;
  DateTime? get selectedDate => _selectedDate;

  // Computed properties
  double get totalSpending =>
      _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  double get monthlySpending {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return _expenses
        .where((expense) =>
            expense.date.isAfter(monthStart) ||
            expense.date.isAtSameMomentAs(monthStart))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get budgetProgress {
    if (_currentBudget == null || _currentBudget!.monthlyBudget == 0) return 0;
    return (monthlySpending / _currentBudget!.monthlyBudget * 100)
        .clamp(0, 100);
  }

  bool get isOverBudget =>
      _currentBudget != null && monthlySpending > _currentBudget!.monthlyBudget;
  bool get isNearThreshold =>
      _currentBudget != null &&
      monthlySpending >= _currentBudget!.thresholdAmount &&
      monthlySpending < _currentBudget!.monthlyBudget;

  // Initialize with user ID
  Future<void> initialize(String userId) async {
    await loadExpenses(userId);
    await loadCurrentBudget(userId);
  }

  // Load expenses
  Future<void> loadExpenses(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      FirebaseService.getExpenses(userId).listen((expenses) {
        _expenses = expenses;
        _applyFilters();
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load expenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load current budget
  Future<void> loadCurrentBudget(String userId) async {
    try {
      _currentBudget = await FirebaseService.getCurrentBudget(userId);
      if (_currentBudget != null) {
        await _updateCategorySpending(userId);
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to load budget: $e');
    }
  }

  // Add expense
  Future<bool> addExpense(ExpenseModel expense) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.addExpense(expense);

      // Update local list
      _expenses.insert(0, expense);
      _applyFilters();

      // Update budget if needed
      if (_currentBudget != null) {
        final updatedBudget = _currentBudget!.copyWith(
          currentSpending: monthlySpending,
          updatedAt: DateTime.now(),
        );
        await FirebaseService.updateBudget(updatedBudget);
        _currentBudget = updatedBudget;
      }

      return true;
    } catch (e) {
      _setError('Failed to add expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update expense
  Future<bool> updateExpense(ExpenseModel expense) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.updateExpense(expense);

      // Update local list
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
        _applyFilters();
      }

      return true;
    } catch (e) {
      _setError('Failed to update expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete expense
  Future<bool> deleteExpense(String expenseId) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.deleteExpense(expenseId);

      // Update local list
      _expenses.removeWhere((expense) => expense.id == expenseId);
      _applyFilters();

      return true;
    } catch (e) {
      _setError('Failed to delete expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Process OCR image
  Future<ExpenseData?> processReceiptImage(File imageFile) async {
    try {
      _setLoading(true);
      _clearError();

      final expenseData = await OCRService.processReceiptImage(imageFile);
      return expenseData;
    } catch (e) {
      _setError('Failed to process receipt: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Set category filter
  void setCategoryFilter(ExpenseCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Set date filter
  void setDateFilter(DateTime? date) {
    _selectedDate = date;
    _applyFilters();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedDate = null;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters
  void _applyFilters() {
    _filteredExpenses = _expenses.where((expense) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!expense.description.toLowerCase().contains(query) &&
            !expense.categoryDisplayName.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && expense.category != _selectedCategory) {
        return false;
      }

      // Date filter
      if (_selectedDate != null) {
        final expenseDate =
            DateTime(expense.date.year, expense.date.month, expense.date.day);
        final filterDate = DateTime(
            _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
        if (expenseDate != filterDate) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Update category spending
  Future<void> _updateCategorySpending(String userId) async {
    try {
      final now = DateTime.now();
      final monthYear = DateTime(now.year, now.month, 1);
      _categorySpending =
          await FirebaseService.getCategoryWiseSpending(userId, monthYear);
    } catch (e) {
      print('Failed to update category spending: $e');
    }
  }

  // Get expenses for specific month
  Future<List<ExpenseModel>> getExpensesForMonth(DateTime monthYear) async {
    try {
      return await FirebaseService.getExpensesForMonth(
          _currentBudget?.userId ?? '', monthYear);
    } catch (e) {
      _setError('Failed to get monthly expenses: $e');
      return [];
    }
  }

  // Get spending by category for month
  Future<Map<String, double>> getCategorySpendingForMonth(
      DateTime monthYear) async {
    try {
      return await FirebaseService.getCategoryWiseSpending(
          _currentBudget?.userId ?? '', monthYear);
    } catch (e) {
      _setError('Failed to get category spending: $e');
      return {};
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
