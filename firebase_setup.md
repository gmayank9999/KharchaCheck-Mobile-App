# Firebase Setup Instructions for KharchaCheck

## Prerequisites
1. A Google account
2. Flutter SDK installed
3. Android Studio or VS Code with Flutter extension

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `kharcha-check` (or your preferred name)
4. Enable Google Analytics (optional but recommended)
5. Click "Create project"

## Step 2: Add Android App

1. In your Firebase project, click "Add app" and select Android
2. Enter your package name: `com.example.kharcha_check`
3. Enter app nickname: `KharchaCheck`
4. Click "Register app"
5. Download the `google-services.json` file
6. Place it in `android/app/` directory

## Step 3: Add iOS App (if developing for iOS)

1. In your Firebase project, click "Add app" and select iOS
2. Enter your bundle ID: `com.example.kharchaCheck`
3. Enter app nickname: `KharchaCheck iOS`
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Place it in `ios/Runner/` directory

## Step 4: Enable Authentication

1. In Firebase Console, go to "Authentication" > "Sign-in method"
2. Enable "Email/Password" provider
3. Optionally enable "Google" sign-in for better UX

## Step 5: Create Firestore Database

1. Go to "Firestore Database" in Firebase Console
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users
5. Click "Done"

## Step 6: Set up Security Rules

Replace the default Firestore rules with these:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can only access their own expenses
    match /expenses/{expenseId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Users can only access their own budgets
    match /budgets/{budgetId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Users can only access their own notifications
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

## Step 7: Enable Cloud Messaging (Optional)

1. Go to "Cloud Messaging" in Firebase Console
2. No additional setup required for basic functionality
3. For production, configure server-side notifications

## Step 8: Update Android Configuration

1. Open `android/app/build.gradle`
2. Add the following inside the `android` block:

```gradle
android {
    // ... existing code ...
    
    compileSdkVersion 34
    
    defaultConfig {
        // ... existing code ...
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

3. Add the following at the bottom of the file:

```gradle
apply plugin: 'com.google.gms.google-services'
```

4. Open `android/build.gradle` (project level)
5. Add the following in the `dependencies` block:

```gradle
dependencies {
    // ... existing code ...
    classpath 'com.google.gms:google-services:4.4.0'
}
```

## Step 9: Update iOS Configuration (if developing for iOS)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Add the `GoogleService-Info.plist` to the Runner target
3. Make sure it's added to the bundle

## Step 10: Test the Setup

1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to test the app
3. Try creating an account and adding an expense

## Troubleshooting

### Common Issues:

1. **Build errors**: Make sure `google-services.json` is in the correct location
2. **Authentication errors**: Check if Email/Password is enabled in Firebase Console
3. **Firestore errors**: Verify security rules and database is created
4. **iOS build errors**: Make sure `GoogleService-Info.plist` is added to Xcode project

### Testing Checklist:

- [ ] User can register with email/password
- [ ] User can login with email/password
- [ ] User can add expenses
- [ ] User can view expense list
- [ ] User can set budget settings
- [ ] OCR scanning works (requires camera permission)
- [ ] Notifications work (requires notification permission)

## Production Considerations

1. **Security Rules**: Update Firestore rules for production
2. **Authentication**: Consider adding additional providers
3. **Monitoring**: Enable Firebase Analytics and Crashlytics
4. **Backup**: Set up automated backups for Firestore
5. **Performance**: Monitor database usage and optimize queries

## Support

If you encounter issues:
1. Check Firebase Console for error logs
2. Verify all configuration files are in place
3. Ensure all dependencies are properly installed
4. Check device permissions for camera and notifications
