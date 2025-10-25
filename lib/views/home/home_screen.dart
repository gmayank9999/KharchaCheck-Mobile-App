import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../constants/app_constants.dart';
import '../expense/add_expense_screen.dart';
import '../expense/expense_list_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/budget_progress_card.dart';
import '../../widgets/expense_summary_card.dart';
import '../../widgets/quick_actions_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeData();
  }

  void _initializeData() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final expenseViewModel =
        Provider.of<ExpenseViewModel>(context, listen: false);

    if (authViewModel.currentUser != null) {
      expenseViewModel.initialize(authViewModel.currentUser!.uid);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          _DashboardPage(),
          ExpenseListScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: AppConstants.mediumAnimation,
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_outlined),
            activeIcon: Icon(Icons.list),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: Consumer2<AuthViewModel, ExpenseViewModel>(
        builder: (context, authViewModel, expenseViewModel, child) {
          if (expenseViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (authViewModel.currentUser != null) {
                await expenseViewModel
                    .initialize(authViewModel.currentUser!.uid);
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Message
                  Text(
                    'Welcome back, ${authViewModel.currentUser?.displayName ?? 'User'}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Here\'s your financial overview for this month',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Budget Progress Card
                  BudgetProgressCard(
                    currentSpending: expenseViewModel.monthlySpending,
                    monthlyBudget:
                        authViewModel.currentUser?.monthlyBudget ?? 0,
                    budgetThreshold:
                        authViewModel.currentUser?.budgetThreshold ?? 80,
                    isOverBudget: expenseViewModel.isOverBudget,
                    isNearThreshold: expenseViewModel.isNearThreshold,
                  ),
                  const SizedBox(height: 16),

                  // Quick Actions
                  QuickActionsCard(
                    onAddExpense: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AddExpenseScreen()),
                      );
                    },
                    onScanReceipt: () {
                      // Handle scan receipt
                    },
                    onViewExpenses: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ExpenseListScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Expense Summary
                  ExpenseSummaryCard(
                    totalSpending: expenseViewModel.monthlySpending,
                    categorySpending: expenseViewModel.categorySpending,
                    recentExpenses: expenseViewModel.expenses.take(5).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
