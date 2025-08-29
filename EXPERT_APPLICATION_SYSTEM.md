# Expert Application System

This document describes the implementation of the "Become an Expert" feature that allows users to apply to become verified experts in the PlantWise app.

## Overview

The expert application system allows users to:
1. Fill out a multi-step application form
2. Submit their application to Firestore
3. Track their application status
4. Receive expert status upon approval

## Architecture

### 1. Model Layer
**File:** `lib/features/profile/domain/models/expert_application.dart`

- **ExpertApplication**: Freezed model representing an expert application
- **ExpertApplicationStatus**: Enum for application states (pending, approved, rejected, under_review)
- Full JSON serialization support for Firestore storage

### 2. Service Layer
**File:** `lib/features/profile/data/services/expert_application_service.dart`

- **ExpertApplicationService**: Handles all Firestore operations
- Methods include:
  - `submitApplication()`: Save application to Firestore
  - `getUserApplication()`: Get user's current application
  - `hasUserApplied()`: Check if user has already applied
  - `watchUserApplication()`: Real-time status updates
  - `updateApplicationStatus()`: Admin function to approve/reject

### 3. Provider Layer
**File:** `lib/features/profile/presentation/providers/expert_application_provider.dart`

- **Riverpod providers** for state management:
  - `expertApplicationServiceProvider`: Service instance
  - `userExpertApplicationProvider`: Current user's application
  - `hasUserAppliedProvider`: Application status check
  - `watchUserApplicationProvider`: Real-time updates
  - `expertApplicationNotifierProvider`: Application submission state

### 4. UI Layer
**File:** `lib/features/profile/presentation/screens/profile_screen.dart`

- **BecomeExpertWizard**: Multi-step application form
- **Steps include:**
  1. Specialty selection (Indoor plants, outdoor gardening, etc.)
  2. Experience level (1-2 years to Professional/Certified)
  3. Biography and credentials input
  4. Review and submission

## Features

### Form Validation
- Step-by-step validation ensures complete information
- Required fields: specialty, experience, bio
- Optional: professional credentials

### Theme Support
- Full dark/light mode compatibility
- Theme-aware colors and proper contrast
- Consistent styling with app design

### Error Handling
- Comprehensive error handling with user-friendly messages
- Loading states during submission
- Success confirmation with application ID

### Real-time Updates
- Users can track application status changes
- Firestore listeners for instant updates
- Status descriptions for each state

## Database Structure

### Firestore Collection: `expert_applications`
```json
{
  "id": "auto_generated_id",
  "userId": "user_firebase_uid",
  "userEmail": "user@example.com", 
  "userName": "User Name",
  "specialty": "Indoor Plant Care",
  "experience": "5-10 years",
  "bio": "User's plant expertise story...",
  "credentials": ["Certified Horticulturist", "..."],
  "status": "pending",
  "submittedAt": "2024-01-01T00:00:00Z",
  "reviewedAt": null,
  "reviewNotes": null,
  "reviewedBy": null
}
```

## Usage

### For Users
1. Navigate to Profile → Become an Expert card
2. Complete the 4-step wizard:
   - Choose specialty area
   - Select experience level  
   - Write bio and add credentials
   - Review and submit
3. Receive confirmation with application ID
4. Track status in real-time

### For Admins
- Use `ExpertApplicationService.updateApplicationStatus()` to approve/reject applications
- Access `getAllApplications()` to review pending applications
- Update status with optional review notes

## Testing

Comprehensive test coverage includes:
- Model creation and JSON serialization
- Status enum display names and descriptions  
- Application lifecycle testing

**Test file:** `test/expert_application_test.dart`

## Security

- User authentication required for submission
- Firestore security rules should restrict:
  - Users can only read/write their own applications
  - Only admins can update application status
  - All fields validated on client and server side

## Future Enhancements

1. **Email notifications** for status changes
2. **Admin dashboard** for reviewing applications
3. **Expert profiles** for approved users
4. **Expert badges** displayed throughout the app
5. **Expert-only features** and privileges

## Files Created/Modified

### New Files:
- `lib/features/profile/domain/models/expert_application.dart`
- `lib/features/profile/data/services/expert_application_service.dart`
- `lib/features/profile/presentation/providers/expert_application_provider.dart`
- `test/expert_application_test.dart`

### Modified Files:  
- `lib/features/profile/presentation/screens/profile_screen.dart` (Added BecomeExpertWizard)

The system is now fully functional and ready for users to apply to become verified experts in the PlantWise community!
