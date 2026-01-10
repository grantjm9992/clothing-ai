# Clothing AI - Mobile App

Flutter mobile application for iOS and Android.

## Tech Stack

- **Framework**: Flutter 3.16+
- **State Management**: Riverpod
- **Navigation**: go_router
- **Local Storage**: Hive
- **Authentication**: Google Sign-In, Sign in with Apple, Facebook Auth
- **Payments**: In-App Purchase (RevenueCat)
- **Analytics**: Firebase Analytics, Crashlytics, Sentry

## Features

- **Fit Check**: Take outfit photos and get AI-powered feedback
- **Wardrobe Management**: Digitize your wardrobe items
- **Outfit Builder**: Generate complete outfits from your wardrobe
- **Saved Outfits**: Save and organize your favorite combinations
- **Subscription Management**: Freemium model with premium features
- **User Profile**: Preferences, style profile, body measurements

## Prerequisites

- Flutter SDK 3.16 or higher
- Dart 3.2 or higher
- Xcode 15+ (for iOS development)
- Android Studio (for Android development)

## Getting Started

### Installation

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Generate code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Run the app:
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

### Development

```bash
# Run with hot reload
flutter run

# Run tests
flutter test

# Generate code
flutter pub run build_runner watch

# Build release
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## Project Structure

```
mobile/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── config/
│   │   ├── constants/
│   │   ├── theme/
│   │   └── utils/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── wardrobe/
│   │   ├── outfit/
│   │   ├── camera/
│   │   └── subscription/
│   ├── shared/
│   │   ├── widgets/
│   │   ├── models/
│   │   └── services/
│   └── routes/
├── test/
├── assets/
└── pubspec.yaml
```

## Features Overview

### Fit Check Flow
1. User opens camera
2. Takes outfit photo
3. Provides context (occasion, weather, vibe)
4. Receives AI feedback and suggestions
5. Can apply suggestions from wardrobe

### Wardrobe Management
1. User photographs wardrobe items
2. AI automatically tags items (category, color, style)
3. User can edit/confirm tags
4. Items stored locally and synced to cloud
5. Search and filter by tags

### Outfit Builder
1. User selects occasion/context
2. AI generates 3 outfit options from wardrobe
3. User can swap individual items
4. Save favorite outfits
5. Create packing lists

## Configuration

### Environment Variables

Create `.env` files for different environments:

`.env.development`:
```
API_BASE_URL=http://localhost:8000/api/v1
AI_SERVICE_URL=http://localhost:8001/api/v1
ENVIRONMENT=development
```

`.env.production`:
```
API_BASE_URL=https://api.clothing-ai.com/api/v1
AI_SERVICE_URL=https://ai.clothing-ai.com/api/v1
ENVIRONMENT=production
```

### Firebase Setup

1. Create Firebase project
2. Add iOS and Android apps
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place in respective platform directories

### Apple Sign In

1. Enable Sign in with Apple in Apple Developer Portal
2. Configure in Xcode signing capabilities

### RevenueCat Setup

1. Create RevenueCat account
2. Configure products
3. Add API key to environment

## Testing

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widgets/

# Integration tests
flutter test integration_test/
```

## Building for Release

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS

```bash
# Build for App Store
flutter build ipa --release
```

## Deployment

See `/docs/mobile-deployment.md` for detailed deployment instructions.

### Fastlane

Fastlane is configured for automated builds and deployments.

```bash
# iOS TestFlight
cd ios && fastlane beta

# Android Play Store
cd android && fastlane beta
```

## State Management

The app uses Riverpod for state management with the following providers:

- **AuthProvider**: User authentication state
- **WardrobeProvider**: Wardrobe items state
- **OutfitProvider**: Outfit sessions state
- **SubscriptionProvider**: User subscription status

## API Integration

All API calls go through the `ApiService` class which handles:
- Authentication headers
- Error handling
- Retry logic
- Request/response logging

## Offline Support

The app supports offline mode with:
- Local caching of wardrobe items
- Queue for uploads when back online
- Optimistic updates

## Performance Optimization

- Image compression before upload
- Lazy loading of wardrobe grid
- Cached network images
- Debounced search
- Pagination for large lists

## Accessibility

- Screen reader support
- Semantic labels
- High contrast mode
- Adjustable text sizes
