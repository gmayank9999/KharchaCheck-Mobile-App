import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/expense_model.dart';
import '../models/budget_model.dart';
import '../constants/app_constants.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth Methods
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // User Authentication
  static Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(displayName);

      // Create user document
      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        monthlyBudget: 0.0,
        budgetThreshold: 80.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .set(userModel.toMap());

      return credential;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // User Profile Methods
  static Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  static Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Expense Methods
  static Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _firestore
          .collection(AppConstants.expensesCollection)
          .doc(expense.id)
          .set(expense.toMap());
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  static Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _firestore
          .collection(AppConstants.expensesCollection)
          .doc(expense.id)
          .update(expense.toMap());
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  static Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore
          .collection(AppConstants.expensesCollection)
          .doc(expenseId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  static Stream<List<ExpenseModel>> getExpenses(String userId) {
    return _firestore
        .collection(AppConstants.expensesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.data()))
          .toList();
    });
  }

  static Future<List<ExpenseModel>> getExpensesForMonth(
    String userId,
    DateTime monthYear,
  ) async {
    try {
      final startOfMonth = DateTime(monthYear.year, monthYear.month, 1);
      final endOfMonth = DateTime(monthYear.year, monthYear.month + 1, 0);

      final querySnapshot = await _firestore
          .collection(AppConstants.expensesCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      return querySnapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get monthly expenses: $e');
    }
  }

  // Budget Methods
  static Future<void> updateBudget(BudgetModel budget) async {
    try {
      await _firestore
          .collection(AppConstants.budgetsCollection)
          .doc(budget.id)
          .set(budget.toMap());
    } catch (e) {
      throw Exception('Failed to update budget: $e');
    }
  }

  static Future<BudgetModel?> getCurrentBudget(String userId) async {
    try {
      final now = DateTime.now();
      final monthYear = DateTime(now.year, now.month, 1);

      final querySnapshot = await _firestore
          .collection(AppConstants.budgetsCollection)
          .where('userId', isEqualTo: userId)
          .where('monthYear', isEqualTo: monthYear)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return BudgetModel.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current budget: $e');
    }
  }

  // File Upload
  static Future<String> uploadImage(String path, String fileName) async {
    try {
      final ref = _storage.ref().child('receipts/$fileName');
      final uploadTask = await ref.putFile(File(path));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Analytics Methods
  static Future<Map<String, double>> getCategoryWiseSpending(
    String userId,
    DateTime monthYear,
  ) async {
    try {
      final expenses = await getExpensesForMonth(userId, monthYear);
      final Map<String, double> categorySpending = {};

      for (final expense in expenses) {
        final category = expense.categoryDisplayName;
        categorySpending[category] =
            (categorySpending[category] ?? 0.0) + expense.amount;
      }

      return categorySpending;
    } catch (e) {
      throw Exception('Failed to get category wise spending: $e');
    }
  }

  static Future<double> getTotalSpendingForMonth(
    String userId,
    DateTime monthYear,
  ) async {
    try {
      final expenses = await getExpensesForMonth(userId, monthYear);
      // Make types explicit to avoid ambiguous FutureOr<double> inference
      return expenses.fold<double>(0.0, (double sum, ExpenseModel expense) {
        return sum + (expense.amount);
      });
    } catch (e) {
      throw Exception('Failed to get total spending: $e');
    }
  }
}
