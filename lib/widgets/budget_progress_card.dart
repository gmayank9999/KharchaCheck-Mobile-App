import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class BudgetProgressCard extends StatelessWidget {
  final double currentSpending;
  final double monthlyBudget;
  final double budgetThreshold;
  final bool isOverBudget;
  final bool isNearThreshold;

  const BudgetProgressCard({
    super.key,
    required this.currentSpending,
    required this.monthlyBudget,
    required this.budgetThreshold,
    required this.isOverBudget,
    required this.isNearThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final progress = monthlyBudget > 0
        ? (currentSpending / monthlyBudget).clamp(0.0, 1.0)
        : 0.0;
    final thresholdProgress =
        monthlyBudget > 0 ? (budgetThreshold / 100).clamp(0.0, 1.0) : 0.0;
    final remaining = monthlyBudget - currentSpending;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Budget',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Circular Progress
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    // Background circle
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey[300]!,
                      ),
                    ),
                    // Progress circle
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(),
                      ),
                    ),
                    // Threshold indicator
                    if (thresholdProgress < 1.0)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ThresholdIndicatorPainter(
                            threshold: thresholdProgress,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    // Center text
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getProgressColor(),
                                ),
                          ),
                          Text(
                            'used',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Budget details
            Row(
              children: [
                Expanded(
                  child: _buildBudgetDetail(
                    'Spent',
                    currentSpending,
                    _getProgressColor(),
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBudgetDetail(
                    'Remaining',
                    remaining,
                    remaining >= 0 ? Colors.green : Colors.red,
                    Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Budget amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Budget',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Text(
                  '${AppConstants.defaultCurrency}${monthlyBudget.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetDetail(
      String label, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${AppConstants.defaultCurrency}${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (isOverBudget) return Colors.red;
    if (isNearThreshold) return Colors.orange;
    return Colors.green;
  }

  Color _getProgressColor() {
    if (isOverBudget) return Colors.red;
    if (isNearThreshold) return Colors.orange;
    return Colors.blue;
  }

  String _getStatusText() {
    if (isOverBudget) return 'OVER BUDGET';
    if (isNearThreshold) return 'NEAR LIMIT';
    return 'ON TRACK';
  }
}

class ThresholdIndicatorPainter extends CustomPainter {
  final double threshold;
  final Color color;

  ThresholdIndicatorPainter({
    required this.threshold,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    final startAngle = -90 * (3.14159 / 180); // Start from top
    final sweepAngle = threshold * 2 * 3.14159; // Convert to radians

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
