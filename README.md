# KharchaCheck 💰

A comprehensive finance management app designed specifically for students to track expenses, manage budgets, and achieve financial goals.

## Features ✨

### 🏠 Dashboard
- **Budget Progress Tracker**: Visual circular progress bar showing monthly spending vs budget
- **Smart Alerts**: Notifications when approaching budget threshold
- **Quick Actions**: Easy access to add expenses, scan receipts, and view reports
- **Monthly Summary**: Category-wise spending breakdown and recent expenses

### 💳 Expense Management
- **Add Expenses**: Simple form with amount, description, category, and date
- **OCR Receipt Scanning**: Take photos of receipts to auto-fill expense details
- **Categories**: Pre-defined categories (Food, Transportation, Entertainment, etc.)
- **Recurring Expenses**: Set up recurring expenses for regular payments
- **Expense History**: Complete list with filtering and search capabilities

### 📊 Budget Management
- **Monthly Budget Setting**: Set your monthly spending limit
- **Threshold Alerts**: Get notified at customizable spending percentages (50-95%)
- **Real-time Tracking**: Live updates of spending progress
- **Budget Analytics**: Visual charts and spending patterns

### 🔐 User Authentication
- **Secure Login**: Email/password authentication via Firebase
- **User Profiles**: Manage personal information and budget settings
- **Data Privacy**: All data is securely stored and user-specific

### 📱 Modern UI/UX
- **Material Design 3**: Clean, modern interface following Google's design guidelines
- **Responsive Layout**: Optimized for different screen sizes
- **Dark/Light Theme**: Automatic theme switching based on system preferences
- **Smooth Animations**: Delightful micro-interactions and transitions

## Tech Stack 🛠️

- **Framework**: Flutter 3.6+
- **State Management**: Provider
- **Architecture**: MVVM (Model-View-ViewModel)
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **OCR**: Google ML Kit Text Recognition
- **Notifications**: Firebase Cloud Messaging
- **Charts**: FL Chart
- **Image Processing**: Image Picker, Camera

## Getting Started 🚀

### Prerequisites
- Flutter SDK 3.6 or higher
- Dart 3.0 or higher
- Android Studio or VS Code
- Firebase project (see [Firebase Setup](firebase_setup.md))

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/kharcha-check.git
   cd kharcha-check
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Follow the [Firebase Setup Guide](firebase_setup.md)
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure 📁

```
lib/
├── constants/          # App constants and configuration
├── models/            # Data models (User, Expense, Budget)
├── viewmodels/        # Business logic and state management
├── views/             # UI screens and pages
│   ├── auth/          # Authentication screens
│   ├── expense/       # Expense-related screens
│   ├── home/          # Dashboard and main screens
│   └── profile/       # User profile and settings
├── services/          # External services (Firebase, OCR, Notifications)
├── widgets/           # Reusable UI components
└── utils/             # Utility functions and helpers
```

## Key Features Implementation 🔧

### MVVM Architecture
- **Models**: Pure data classes representing app entities
- **ViewModels**: Handle business logic and state management
- **Views**: UI components that observe ViewModels

### Firebase Integration
- **Authentication**: Secure user registration and login
- **Firestore**: Real-time database for expenses and budgets
- **Storage**: Receipt image storage
- **Cloud Messaging**: Push notifications for budget alerts

### OCR Functionality
- **Receipt Scanning**: Camera integration for receipt capture
- **Text Recognition**: Google ML Kit for text extraction
- **Smart Parsing**: Automatic amount, description, and category detection
- **Manual Override**: Edit OCR results for accuracy

### Budget Management
- **Real-time Tracking**: Live budget progress updates
- **Threshold Alerts**: Customizable spending notifications
- **Category Analysis**: Detailed spending breakdown by category
- **Monthly Reports**: Comprehensive spending summaries

## Screenshots 📸

*Screenshots will be added after UI completion*

## Contributing 🤝

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Development Roadmap 🗺️

### Phase 1 (Current)
- [x] Basic expense tracking
- [x] Budget management
- [x] User authentication
- [x] OCR receipt scanning
- [x] Basic UI/UX

### Phase 2 (Planned)
- [ ] Advanced analytics and reports
- [ ] Export functionality (PDF, CSV)
- [ ] Multiple currency support
- [ ] Goal setting and tracking
- [ ] Social features (shared budgets)

### Phase 3 (Future)
- [ ] AI-powered spending insights
- [ ] Investment tracking
- [ ] Bill reminders
- [ ] Integration with banking APIs
- [ ] Advanced budgeting strategies

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support 💬

- **Issues**: [GitHub Issues](https://github.com/yourusername/kharcha-check/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/kharcha-check/discussions)
- **Email**: support@kharchacheck.com

## Acknowledgments 🙏

- Flutter team for the amazing framework
- Firebase for backend services
- Google ML Kit for OCR capabilities
- Material Design team for design guidelines
- Open source community for inspiration and libraries

---

**Made with ❤️ for students by students**