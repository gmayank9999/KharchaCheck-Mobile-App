class BudgetModel {
  final String id;
  final String userId;
  final double monthlyBudget;
  final double budgetThreshold; // Percentage (0-100)
  final double currentSpending;
  final DateTime monthYear; // First day of the month
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.monthlyBudget,
    required this.budgetThreshold,
    required this.currentSpending,
    required this.monthYear,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      monthlyBudget: (map['monthlyBudget'] ?? 0.0).toDouble(),
      budgetThreshold: (map['budgetThreshold'] ?? 0.0).toDouble(),
      currentSpending: (map['currentSpending'] ?? 0.0).toDouble(),
      monthYear: DateTime.fromMillisecondsSinceEpoch(map['monthYear'] ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'monthlyBudget': monthlyBudget,
      'budgetThreshold': budgetThreshold,
      'currentSpending': currentSpending,
      'monthYear': monthYear.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  BudgetModel copyWith({
    String? id,
    String? userId,
    double? monthlyBudget,
    double? budgetThreshold,
    double? currentSpending,
    DateTime? monthYear,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      budgetThreshold: budgetThreshold ?? this.budgetThreshold,
      currentSpending: currentSpending ?? this.currentSpending,
      monthYear: monthYear ?? this.monthYear,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get spendingPercentage {
    if (monthlyBudget == 0) return 0;
    return (currentSpending / monthlyBudget) * 100;
  }

  double get thresholdAmount {
    return (monthlyBudget * budgetThreshold) / 100;
  }

  bool get isOverBudget {
    return currentSpending > monthlyBudget;
  }

  bool get isNearThreshold {
    return currentSpending >= thresholdAmount &&
        currentSpending < monthlyBudget;
  }

  double get remainingBudget {
    return monthlyBudget - currentSpending;
  }

  bool get isThresholdReached {
    return currentSpending >= thresholdAmount;
  }
}
