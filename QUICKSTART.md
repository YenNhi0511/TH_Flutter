# Quickstart Guide - Mạng Xã Hội Chia Sẻ Ảnh

## Getting Started

### 1. Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK (included with Flutter)
- Firebase account (for backend services)
- Android Studio / Xcode (for emulator/device testing)

### 2. Installation

```bash
# Navigate to the project directory
cd mangxahoi

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### 3. Firebase Setup

#### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project named "mangxahoi"
3. Enable the following services:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Cloud Storage

#### Step 2: Connect to Flutter App

1. Install Firebase CLI:

   ```bash
   npm install -g firebase-tools
   ```

2. Authenticate with Firebase:

   ```bash
   firebase login
   ```

3. Generate Firebase config for Flutter:
   ```bash
   flutterfire configure
   ```
   - Select your Firebase project
   - Choose platforms (Android, iOS, Web, etc.)

#### Step 3: Update Firebase Security Rules

**Cloud Firestore Rules:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /posts/{postId} {
      allow read: if true;
      allow create, update: if request.auth.uid == resource.data.userId;
      allow delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

**Cloud Storage Rules:**

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /images/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

### 4. Test Account Setup

Create a test account in Firebase Authentication:

- **Email**: test@example.com
- **Password**: Test123456!

Or register a new account using the app's Sign Up page.

## App Features

### Authentication Page

- **Login Tab**: Enter email and password to access your feed
- **Sign Up Tab**: Create a new account to start sharing
- Automatic validation and error messages

### Home Page

After successful login:

- **Camera Button**: Take a photo directly
- **Gallery Button**: Select image from device storage
- **Upload Button**: Upload selected image to Firebase
- **Logout Button**: Exit the application

## Testing Workflow

### Manual Testing Checklist

- [ ] App launches successfully
- [ ] Authentication page displays both tabs
- [ ] Can sign up with valid email/password
- [ ] Can log in with registered credentials
- [ ] Error handling for invalid credentials
- [ ] Can pick image from camera
- [ ] Can pick image from gallery
- [ ] Can see image preview after selection
- [ ] Can log out successfully
- [ ] Redirected to auth page after logout

### Build Commands

```bash
# Clean build
flutter clean
flutter pub get

# Analyze code
flutter analyze

# Build APK (Android)
flutter build apk

# Build iOS
flutter build ios

# Build web
flutter build web
```

## Troubleshooting

### Firebase Dependency Issues

```bash
# Update packages
flutter pub upgrade

# Pub cache clean
flutter pub cache clean
flutter pub get
```

### Hot Reload Not Working

```bash
# Stop the app and rebuild
flutter clean
flutter pub get
flutter run
```

### Android Build Issues

```bash
# Invalidate cache
rm -rf android/build
flutter clean
flutter pub get
flutter run
```

## Project Architecture

```
mangxahoi/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── features/
│   │   ├── auth/
│   │   │   ├── domain/           # Business logic
│   │   │   ├── data/             # API/Database access
│   │   │   └── presentation/     # UI components
│   │   └── posts/
│   │       ├── domain/           # Business logic
│   │       ├── data/             # API/Database access
│   │       └── presentation/     # UI components
│   └── core/                     # Utilities and constants
├── test/                         # Unit and widget tests
└── pubspec.yaml                  # Dependencies
```

## Development Guidelines

### Code Style

- Follow Dart style guide
- Use meaningful variable names
- Comment complex logic
- Keep functions focused and small

### Git Workflow

```bash
# Create a feature branch
git checkout -b feature/feature-name

# Make changes and commit
git add .
git commit -m "feat: describe your changes"

# Push to remote
git push origin feature/feature-name
```

## Performance Tips

- Use `const` constructors where possible
- Cache images with `cached_network_image`
- Dispose controllers in `dispose()` method
- Use `FutureBuilder` for async operations

## Useful Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design](https://material.io/design)

## Support & Questions

For issues or questions:

1. Check Flutter documentation first
2. Review error messages carefully
3. Check Firebase logs in console
4. Test with simple examples first
5. Use debugging tools (DevTools)

---

**Last Updated**: 2024
**Status**: In Development 🚀
