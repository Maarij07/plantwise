# PlantWise - Plant Care Companion App

A cross-platform mobile app for plant care, gardening guidance, and community support built with Flutter.

## 🌱 Project Overview

PlantWise is designed to help users care for their plants with personalized care reminders, expert guidance, and community support. The app includes both user and admin functionality.

## 🏗️ Project Structure

This project follows **Clean Architecture** principles with a feature-based folder structure:

```
lib/
├── config/
│   ├── routes/
│   │   └── app_router.dart          # Go Router configuration
│   └── theme/
│       └── app_theme.dart           # App theming and colors
├── core/
│   └── constants/
│       └── app_constants.dart       # App-wide constants
├── features/
│   ├── splash/
│   │   └── presentation/
│   │       └── screens/
│   │           └── splash_screen.dart
│   ├── onboarding/
│   │   └── presentation/
│   │       └── screens/
│   │           └── onboarding_screen.dart
│   ├── authentication/
│   │   └── presentation/
│   │       └── screens/
│   │           ├── sign_in_screen.dart
│   │           ├── sign_up_screen.dart
│   │           └── forgot_password_screen.dart
│   ├── home/
│   │   └── presentation/
│   │       └── screens/
│   │           └── home_screen.dart
│   └── admin/
│       └── presentation/
│           └── screens/
│               └── admin_screen.dart
└── main.dart                        # App entry point
```

## 🚀 App Flow

### User Journey
1. **Splash Screen** - App logo and initialization (3 seconds)
2. **Onboarding** - 3 screens introducing app features
3. **Authentication** - Sign in, Sign up, or Forgot password
4. **Home Screen** - Main user dashboard with 4 tabs:
   - Dashboard (plant care summary, tasks)
   - My Plants
   - Community
   - Profile

### Admin Journey
1. **Same as user** until authentication
2. **Admin Login** - Use admin credentials:
   - Email: `admin@gmail.com`
   - Password: `12345678`
3. **Admin Screen** - Admin dashboard with 4 tabs:
   - Overview (platform statistics, activity)
   - Users (user management)
   - Plants (plant database)
   - Settings (admin settings)

## 🎨 Design System

### Color Palette
- **Primary**: `#2E7D32` (Green 700)
- **Secondary**: `#8BC34A` (Light Green 600)
- **Background**: `#F8F9FA` (Grey 50)
- **Surface**: `#FFFFFF`
- **Error**: `#D32F2F`

### Typography
- **Font Family**: Poppins (Google Fonts)
- **Sizes**: 32px (Headline), 28px (Title), 16px (Body), 14px (Caption)

## 🏗️ Application Modules & Features

### Module 1: Core Infrastructure ✅ COMPLETED
**Status:** Fully Implemented
- ✅ Splash screen with animations
- ✅ 3-page onboarding flow
- ✅ Clean architecture with feature-based structure
- ✅ Responsive design with Material 3
- ✅ Dark theme support
- ✅ Navigation system with Go Router
- ✅ State management with Riverpod

### Module 2: User Authentication & Profiles ✅ BASIC IMPLEMENTED
**Status:** Basic implementation complete, needs enhancement
- ✅ User login/signup system
- ✅ Forgot password functionality
- ✅ Admin authentication with special credentials
- 🚧 **TO IMPLEMENT:**
  - Profile image upload
  - Location-based suggestions
  - User activity history/records
  - Crop growing history tracking

### Module 3: Crop Reminders & Notifications 🔄 PARTIALLY IMPLEMENTED
**Status:** Basic UI exists, core functionality needed
- ✅ Notification screen UI
- ✅ Basic task display on dashboard
- 🚧 **TO IMPLEMENT:**
  - Crop type input and date selection
  - Smart reminder system for:
    - Watering schedules
    - Fertilizing cycles
    - Harvesting dates
  - Push notification system
  - Lifecycle-based reminder triggers
  - Reminder customization per crop type

### Module 4: AI-Powered Fertilizer Recommendation Engine 🆕 NOT IMPLEMENTED
**Status:** Complete new development required
- 🚧 **TO IMPLEMENT:**
  - Crop type selection interface
  - Soil condition assessment form
  - Growth stage tracking
  - AI analysis engine for:
    - Fertilizer type recommendations
    - Optimal application amounts
    - Ideal timing suggestions
    - Agronomic explanations
  - Crop-nutrient knowledge base
  - Machine learning feedback system
  - Community feedback integration

### Module 5: Community Q&A Forum 🔄 PARTIALLY IMPLEMENTED
**Status:** Basic structure exists, needs full implementation
- ✅ Community screen UI structure
- ✅ Community post data models
- ✅ Comments system data structure
- 🚧 **TO IMPLEMENT:**
  - Question posting interface
  - Response/answer system
  - Upvote/downvote functionality
  - User reputation system
  - Search and filtering
  - Image attachments for posts
  - Category/tagging system

### Module 6: Plant Management System 🔄 PARTIALLY IMPLEMENTED
**Status:** Data models exist, UI screens need implementation
- ✅ Plant data models with Freezed
- ✅ Plant provider structure
- ✅ My Plants screen placeholder
- 🚧 **TO IMPLEMENT:**
  - Add plant interface
  - Plant detail views
  - Plant editing functionality
  - Camera-based plant identification
  - Plant health tracking
  - Care schedule management
  - Plant image gallery

### Module 7: Admin Panel & Content Management ✅ BASIC IMPLEMENTED
**Status:** Basic admin interface exists, needs feature completion
- ✅ Admin authentication system
- ✅ Admin dashboard UI
- 🚧 **TO IMPLEMENT:**
  - User metrics and analytics
  - Forum moderation tools
  - Content management system
  - Inappropriate content reporting
  - User management (ban/suspend)
  - App content updates
  - System configuration

### Module 8: Advanced Features 🆕 NOT IMPLEMENTED
**Status:** Future enhancements
- 🚧 **TO IMPLEMENT:**
  - Weather integration
  - Seasonal growing guides
  - Pest and disease identification
  - Market price tracking
  - Yield tracking and analytics
  - Social sharing features
  - Offline mode support

### Screens Overview

#### Splash Screen
- Animated logo and app name
- 3-second timer before navigation
- Gradient background

#### Onboarding
- 3 screens with illustrations
- Page indicators
- Skip and navigation buttons
- Smooth transitions

#### Authentication
- **Sign In**: Email/password with admin detection
- **Sign Up**: Full registration form with validation
- **Forgot Password**: Email recovery with confirmation

#### Home Screen (Users)
- **Dashboard**: Welcome card, plant stats, today's tasks
- **My Plants**: Plant management (placeholder)
- **Community**: Social features (placeholder)
- **Profile**: User settings (placeholder)

#### Admin Screen
- **Overview**: Platform stats, recent activity
- **Users**: User management (placeholder)
- **Plants**: Plant database (placeholder)
- **Settings**: Admin configuration (placeholder)

## 🛠️ Technical Details

### Dependencies
- **State Management**: Riverpod
- **Navigation**: Go Router
- **UI**: Material 3, Google Fonts
- **Development**: Clean Architecture principles

### Key Features
- Responsive design for all screen sizes
- Material 3 design system
- Type-safe navigation with Go Router
- Centralized state management with Riverpod
- Comprehensive form validation
- Loading states and error handling

## 🚦 Getting Started

1. Ensure Flutter SDK is installed
2. Run `flutter pub get` to install dependencies
3. Run `flutter run --debug` to start the app

### Admin Access
- **Email**: admin@gmail.com
- **Password**: 12345678

### Navigation Flow
```
Splash (3s) → Onboarding → Sign In → Home/Admin
             ↓
         Skip available
```

## 🎯 Next Steps

The current implementation provides a solid foundation. Future enhancements could include:

1. **Backend Integration**
   - Firebase Auth for authentication
   - Firestore for data storage
   - Cloud Storage for images

2. **Feature Development**
   - Plant identification using camera
   - Care reminders and notifications
   - Community features (posts, comments)
   - Plant health tracking
   - Weather integration

3. **Enhanced UI/UX**
   - Advanced animations
   - Custom illustrations
   - Offline support
   - Multi-language support

## 📦 Assets Structure

```
assets/
├── images/          # App images and illustrations
├── icons/           # Custom icons
├── fonts/           # Custom fonts (Poppins already configured)
└── data/            # JSON data files
```

The project is architected to be easily extensible with additional features while maintaining clean separation of concerns and scalability.
