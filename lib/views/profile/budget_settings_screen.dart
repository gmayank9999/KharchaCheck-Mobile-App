import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../constants/app_constants.dart';

class BudgetSettingsScreen extends StatefulWidget {
  const BudgetSettingsScreen({super.key});

  @override
  State<BudgetSettingsScreen> createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends State<BudgetSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  double _budgetThreshold = 80.0;

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.currentUser;

    if (user != null) {
      _budgetController.text = user.monthlyBudget.toString();
      _budgetThreshold = user.budgetThreshold;
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final budget = double.parse(_budgetController.text);

    final success = await authViewModel.updateProfile(
      monthlyBudget: budget,
      budgetThreshold: _budgetThreshold,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget settings updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(authViewModel.errorMessage ?? 'Failed to update settings'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Settings'),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly Budget Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Budget',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set your monthly spending limit to track your expenses effectively.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Monthly Budget',
                          prefixText: AppConstants.defaultCurrency,
                          prefixIcon: const Icon(Icons.account_balance_wallet),
                          hintText: '0.00',
                          helperText: 'Enter your monthly budget amount',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your monthly budget';
                          }
                          final budget = double.tryParse(value);
                          if (budget == null || budget <= 0) {
                            return 'Please enter a valid budget amount';
                          }
                          if (budget > 1000000) {
                            return 'Budget amount too high';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Budget Threshold Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alert Threshold',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get notified when you reach this percentage of your budget.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Threshold Slider
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Threshold: ${_budgetThreshold.toStringAsFixed(0)}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getThresholdColor().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getThresholdText(),
                                  style: TextStyle(
                                    color: _getThresholdColor(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Slider(
                            value: _budgetThreshold,
                            min: 50,
                            max: 95,
                            divisions: 9,
                            label: '${_budgetThreshold.toStringAsFixed(0)}%',
                            onChanged: (value) {
                              setState(() {
                                _budgetThreshold = value;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('50%',
                                  style: TextStyle(color: Colors.grey[600])),
                              Text('95%',
                                  style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Quick Threshold Options
                      Text(
                        'Quick Options:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: AppConstants.budgetThresholdOptions
                            .map((threshold) {
                          final isSelected = _budgetThreshold == threshold;
                          return FilterChip(
                            label: Text('${threshold.toStringAsFixed(0)}%'),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _budgetThreshold = threshold.toDouble();
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Budget Preview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget Preview',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      _buildPreviewRow(
                        'Monthly Budget',
                        '${AppConstants.defaultCurrency}${_budgetController.text.isEmpty ? '0' : _budgetController.text}',
                        Icons.account_balance_wallet,
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildPreviewRow(
                        'Alert at',
                        '${AppConstants.defaultCurrency}${_getAlertAmount()}',
                        Icons.notifications,
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildPreviewRow(
                        'Remaining after alert',
                        '${AppConstants.defaultCurrency}${_getRemainingAfterAlert()}',
                        Icons.savings,
                        Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    return ElevatedButton(
                      onPressed: authViewModel.isLoading ? null : _handleSave,
                      child: authViewModel.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Save Settings'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getAlertAmount() {
    final budget = double.tryParse(_budgetController.text) ?? 0;
    return ((budget * _budgetThreshold) / 100).toStringAsFixed(0);
  }

  String _getRemainingAfterAlert() {
    final budget = double.tryParse(_budgetController.text) ?? 0;
    final alertAmount = (budget * _budgetThreshold) / 100;
    return (budget - alertAmount).toStringAsFixed(0);
  }

  Color _getThresholdColor() {
    if (_budgetThreshold >= 90) return Colors.red;
    if (_budgetThreshold >= 80) return Colors.orange;
    return Colors.green;
  }

  String _getThresholdText() {
    if (_budgetThreshold >= 90) return 'HIGH';
    if (_budgetThreshold >= 80) return 'MEDIUM';
    return 'LOW';
  }
}
