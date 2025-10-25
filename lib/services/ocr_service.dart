import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../models/expense_model.dart';
import '../constants/app_constants.dart';

class OCRService {
  static final TextRecognizer _textRecognizer = TextRecognizer();
  static final ImagePicker _imagePicker = ImagePicker();

  // Pick image from camera or gallery
  static Future<File?> pickImage({bool fromCamera = true}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: AppConstants.maxImageSize.toDouble(),
        maxHeight: AppConstants.maxImageSize.toDouble(),
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Extract text from image
  static Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      return recognizedText.text;
    } catch (e) {
      throw Exception('Failed to extract text: $e');
    }
  }

  // Parse expense data from OCR text
  static ExpenseData? parseExpenseFromText(String text) {
    try {
      final lines =
          text.split('\n').where((line) => line.trim().isNotEmpty).toList();

      double? amount;
      String description = '';
      ExpenseCategory category = ExpenseCategory.other;

      // Extract amount (look for currency symbols and numbers)
      final amountRegex = RegExp(r'[₹$€£¥]?\s*(\d+(?:\.\d{2})?)');
      for (final line in lines) {
        final match = amountRegex.firstMatch(line);
        if (match != null) {
          final amountStr = match.group(1);
          if (amountStr != null) {
            amount = double.tryParse(amountStr);
            if (amount != null && amount > 0) {
              description = line.replaceAll(amountRegex, '').trim();
              break;
            }
          }
        }
      }

      // If no amount found, try to find the largest number
      if (amount == null) {
        double maxAmount = 0;
        String? bestLine;

        for (final line in lines) {
          final numbers = RegExp(r'\d+(?:\.\d{2})?').allMatches(line);
          for (final match in numbers) {
            final num = double.tryParse(match.group(0) ?? '');
            if (num != null && num > maxAmount && num < 100000) {
              maxAmount = num;
              bestLine = line;
            }
          }
        }

        if (maxAmount > 0) {
          amount = maxAmount;
          description =
              bestLine?.replaceAll(RegExp(r'\d+(?:\.\d{2})?'), '').trim() ?? '';
        }
      }

      // Categorize based on keywords
      final lowerText = text.toLowerCase();
      if (lowerText.contains('food') ||
          lowerText.contains('restaurant') ||
          lowerText.contains('cafe') ||
          lowerText.contains('dining')) {
        category = ExpenseCategory.food;
      } else if (lowerText.contains('fuel') ||
          lowerText.contains('petrol') ||
          lowerText.contains('transport') ||
          lowerText.contains('uber') ||
          lowerText.contains('ola') ||
          lowerText.contains('metro')) {
        category = ExpenseCategory.transportation;
      } else if (lowerText.contains('movie') ||
          lowerText.contains('cinema') ||
          lowerText.contains('entertainment') ||
          lowerText.contains('game')) {
        category = ExpenseCategory.entertainment;
      } else if (lowerText.contains('book') ||
          lowerText.contains('education') ||
          lowerText.contains('course') ||
          lowerText.contains('college')) {
        category = ExpenseCategory.education;
      } else if (lowerText.contains('medical') ||
          lowerText.contains('hospital') ||
          lowerText.contains('pharmacy') ||
          lowerText.contains('doctor')) {
        category = ExpenseCategory.healthcare;
      } else if (lowerText.contains('shop') ||
          lowerText.contains('mall') ||
          lowerText.contains('store') ||
          lowerText.contains('clothes')) {
        category = ExpenseCategory.shopping;
      } else if (lowerText.contains('electricity') ||
          lowerText.contains('water') ||
          lowerText.contains('internet') ||
          lowerText.contains('mobile')) {
        category = ExpenseCategory.utilities;
      } else if (lowerText.contains('rent') ||
          lowerText.contains('room') ||
          lowerText.contains('hostel') ||
          lowerText.contains('pg')) {
        category = ExpenseCategory.rent;
      }

      if (amount != null && amount > 0) {
        return ExpenseData(
          amount: amount,
          description:
              description.isNotEmpty ? description : 'OCR Scanned Receipt',
          category: category,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to parse expense data: $e');
    }
  }

  // Process image and return expense data
  static Future<ExpenseData?> processReceiptImage(File imageFile) async {
    try {
      final text = await extractTextFromImage(imageFile);
      return parseExpenseFromText(text);
    } catch (e) {
      throw Exception('Failed to process receipt: $e');
    }
  }

  // Dispose resources
  static Future<void> dispose() async {
    await _textRecognizer.close();
  }
}

class ExpenseData {
  final double amount;
  final String description;
  final ExpenseCategory category;

  ExpenseData({
    required this.amount,
    required this.description,
    required this.category,
  });
}
