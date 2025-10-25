import 'package:uuid/uuid.dart';

enum ExpenseCategory {
  food,
  transportation,
  entertainment,
  education,
  healthcare,
  shopping,
  utilities,
  rent,
  other,
}

// Extension to provide display name and icon directly on the enum
extension ExpenseCategoryExtension on ExpenseCategory {
  String get categoryDisplayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.transportation:
        return 'Transportation';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.healthcare:
        return 'Healthcare';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.rent:
        return 'Rent & Housing';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.food:
        return '🍽️';
      case ExpenseCategory.transportation:
        return '🚗';
      case ExpenseCategory.entertainment:
        return '🎬';
      case ExpenseCategory.education:
        return '📚';
      case ExpenseCategory.healthcare:
        return '🏥';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.utilities:
        return '⚡';
      case ExpenseCategory.rent:
        return '🏠';
      case ExpenseCategory.other:
        return '📝';
    }
  }
}

class ExpenseModel {
  final String id;
  final String userId;
  final double amount;
  final ExpenseCategory category;
  final String description;
  final DateTime date;
  final bool isRecurring;
  final String? recurringType; // daily, weekly, monthly
  final String? imageUrl; // For OCR scanned receipts
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseModel({
    String? id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.isRecurring = false,
    this.recurringType,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const Uuid().v4();

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.toString() == 'ExpenseCategory.${map['category']}',
        orElse: () => ExpenseCategory.other,
      ),
      description: map['description'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      isRecurring: map['isRecurring'] ?? false,
      recurringType: map['recurringType'],
      imageUrl: map['imageUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'category': category.toString().split('.').last,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'isRecurring': isRecurring,
      'recurringType': recurringType,
      'imageUrl': imageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  ExpenseModel copyWith({
    String? id,
    String? userId,
    double? amount,
    ExpenseCategory? category,
    String? description,
    DateTime? date,
    bool? isRecurring,
    String? recurringType,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get categoryDisplayName {
    switch (category) {
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.transportation:
        return 'Transportation';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.healthcare:
        return 'Healthcare';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.rent:
        return 'Rent & Housing';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  String get categoryIcon {
    switch (category) {
      case ExpenseCategory.food:
        return '🍽️';
      case ExpenseCategory.transportation:
        return '🚗';
      case ExpenseCategory.entertainment:
        return '🎬';
      case ExpenseCategory.education:
        return '📚';
      case ExpenseCategory.healthcare:
        return '🏥';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.utilities:
        return '⚡';
      case ExpenseCategory.rent:
        return '🏠';
      case ExpenseCategory.other:
        return '📝';
    }
  }
}
