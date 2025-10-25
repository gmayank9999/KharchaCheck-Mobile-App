class AppConstants {
  // App Info
  static const String appName = 'KharchaCheck';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String expensesCollection = 'expenses';
  static const String budgetsCollection = 'budgets';
  static const String notificationsCollection = 'notifications';

  // Shared Preferences Keys
  static const String isFirstTimeKey = 'is_first_time';
  static const String userUidKey = 'user_uid';
  static const String budgetThresholdKey = 'budget_threshold';
  static const String monthlyBudgetKey = 'monthly_budget';

  // Notification Channels
  static const String budgetAlertChannelId = 'budget_alert_channel';
  static const String budgetAlertChannelName = 'Budget Alerts';
  static const String budgetAlertChannelDescription =
      'Notifications for budget threshold alerts';

  // OCR Settings
  static const double minConfidenceThreshold = 0.7;
  static const int maxImageSize = 1024;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Currency
  static const String defaultCurrency = '₹';
  static const String currencyCode = 'INR';

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';
  static const String monthYearFormat = 'MMM yyyy';

  // Validation
  static const double minAmount = 0.01;
  static const double maxAmount = 999999.99;
  static const int maxDescriptionLength = 200;
  static const int maxCategoryNameLength = 50;

  // Chart Colors
  static const List<int> chartColors = [
    0xFF2196F3, // Blue
    0xFF4CAF50, // Green
    0xFFFF9800, // Orange
    0xFFE91E63, // Pink
    0xFF9C27B0, // Purple
    0xFF00BCD4, // Cyan
    0xFFFF5722, // Deep Orange
    0xFF795548, // Brown
    0xFF607D8B, // Blue Grey
  ];

  // Budget Threshold Options
  static const List<double> budgetThresholdOptions = [50, 60, 70, 80, 90, 95];

  // Recurring Types
  static const List<String> recurringTypes = ['daily', 'weekly', 'monthly'];

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String authError = 'Authentication failed. Please login again.';
  static const String validationError =
      'Please fill all required fields correctly.';
}
