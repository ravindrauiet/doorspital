# API Integration Summary

This document summarizes all the backend APIs that have been integrated into the Flutter app.

## Base Configuration

- **Base URL**: `http://localhost:3000/api` (or `http://10.0.2.2:3000/api` for Android emulator)
- **Authentication**: JWT Bearer tokens stored in SharedPreferences
- **All services are located in**: `lib/services/`

## Integrated APIs

### 1. Authentication APIs (`AuthService`)

#### ✅ POST `/api/auth/sign-up`
- **Service Method**: `AuthService.signUp()`
- **Model**: `SignUpRequest`
- **Status**: ✅ Integrated
- **Usage**: User registration with userName, email, and password

#### ✅ POST `/api/auth/sign-in`
- **Service Method**: `AuthService.signIn()`
- **Model**: `SignInRequest`
- **Status**: ✅ Integrated
- **Usage**: User login, returns JWT token and user data
- **UI Integration**: ✅ Sign-in screen updated

### 2. Doctor APIs (`DoctorService`)

#### ✅ GET `/api/doctors/top`
- **Service Method**: `DoctorService.getTopDoctors()`
- **Status**: ✅ Integrated
- **Query Params**: specialization, city, page, limit

#### ✅ POST `/api/doctors/sign-up`
- **Service Method**: `DoctorService.doctorSignUp()`
- **Model**: `DoctorSignUpRequest`
- **Status**: ✅ Integrated
- **Usage**: Doctor registration

#### ✅ GET `/api/doctors/verification/:doctorId`
- **Service Method**: `DoctorService.getVerificationStatus()`
- **Status**: ✅ Integrated
- **Usage**: Get verification status for a doctor

#### ✅ POST `/api/doctors/verification/submit`
- **Service Method**: `DoctorService.submitVerification()`
- **Model**: `DoctorVerificationRequest`
- **Status**: ✅ Integrated
- **Usage**: Submit doctor verification documents (multipart file upload)

#### ✅ POST `/api/doctors/:doctorId/availability/set`
- **Service Method**: `DoctorService.setAvailability()`
- **Model**: `SetAvailabilityRequest`
- **Status**: ✅ Integrated
- **Usage**: Set doctor's weekly availability schedule
- **Note**: Requires authentication

#### ✅ GET `/api/doctors/:doctorId/availability/schedule`
- **Service Method**: `DoctorService.getAvailabilitySchedule()`
- **Status**: ✅ Integrated
- **Query Params**: start, days, tz
- **Usage**: Get doctor's availability schedule

### 3. Appointment APIs (`AppointmentService`)

#### ✅ GET `/api/appointments/doctors/available`
- **Service Method**: `AppointmentService.searchAvailableDoctors()`
- **Status**: ✅ Integrated
- **Query Params**: date (required), specialization, city
- **Usage**: Search for available doctors on a specific date

#### ✅ POST `/api/appointments/book`
- **Service Method**: `AppointmentService.bookAppointment()`
- **Model**: `BookAppointmentRequest`
- **Status**: ✅ Integrated
- **Usage**: Book an appointment with a doctor
- **Note**: Requires authentication

#### ✅ GET `/api/appointments/my-appointments`
- **Service Method**: `AppointmentService.getMyAppointments()`
- **Status**: ✅ Integrated
- **Query Params**: status, page, limit
- **Usage**: Get user's appointments
- **Note**: Requires authentication

#### ✅ PUT `/api/appointments/:appointmentId/cancel`
- **Service Method**: `AppointmentService.cancelAppointment()`
- **Status**: ✅ Integrated
- **Usage**: Cancel an appointment
- **Note**: Requires authentication

## Service Files Structure

```
lib/services/
├── api_client.dart              # Base HTTP client with JWT management
├── auth_service.dart            # Authentication APIs
├── doctor_service.dart          # Doctor-related APIs
├── appointment_service.dart     # Appointment APIs
├── models/
│   ├── api_response.dart       # Generic API response wrapper
│   ├── auth_models.dart        # Auth request/response models
│   ├── doctor_models.dart      # Doctor-related models
│   └── appointment_models.dart # Appointment models
└── api_usage_examples.dart     # Usage examples for all APIs
```

## Models

### Auth Models
- `SignUpRequest` - User registration
- `SignInRequest` - User login
- `User` - User data model
- `SignInResponse` - Sign-in response with token

### Doctor Models
- `DoctorSignUpRequest` - Doctor registration
- `Doctor` - Doctor data model
- `DoctorVerificationRequest` - Verification submission
- `AvailabilityRule` - Single availability rule
- `SetAvailabilityRequest` - Set availability request
- `AvailabilityResponse` - Availability schedule response
- `TimeSlot` - Time slot model
- `DayAvailability` - Day availability model

### Appointment Models
- `BookAppointmentRequest` - Book appointment request
- `Appointment` - Appointment data model
- `AvailableDoctor` - Available doctor with slots
- `SearchAvailableDoctorsResponse` - Search response

## Authentication Flow

1. User signs in → `AuthService.signIn()` → Token saved automatically
2. All authenticated requests include token in `Authorization: Bearer <token>` header
3. Token is stored in SharedPreferences and automatically included in requests
4. Use `AuthService.signOut()` to clear token

## Usage Example

```dart
// Sign in
final authService = AuthService();
final response = await authService.signIn(
  SignInRequest(email: 'user@example.com', password: 'password'),
);

if (response.success) {
  // User is now authenticated, token is saved automatically
  // Navigate to home screen
}

// Get top doctors
final doctorService = DoctorService();
final doctorsResponse = await doctorService.getTopDoctors(
  specialization: 'Cardiology',
  city: 'Mumbai',
);

// Book appointment
final appointmentService = AppointmentService();
final bookResponse = await appointmentService.bookAppointment(
  BookAppointmentRequest(
    doctorId: 'doctor_id',
    startTime: '2025-11-24T10:00:00Z',
    mode: 'online',
  ),
);
```

## UI Integration Status

- ✅ Sign In Screen - Integrated with `AuthService.signIn()`
- ✅ Sign Up Screen - Integrated with `AuthService.signUp()`
- ⏳ Other screens - Ready for integration (services are available)

## Notes

1. **File Uploads**: Doctor verification uses multipart file uploads. See `DoctorService.submitVerification()` for example.

2. **Error Handling**: All services return `ApiResponse<T>` which includes:
   - `success`: Boolean indicating success/failure
   - `message`: Error or success message
   - `data`: Response data (if successful)
   - `errors`: Validation errors (if any)

3. **Network Configuration**: The base URL automatically adjusts for:
   - Android emulator: `10.0.2.2:3000`
   - iOS simulator: `127.0.0.1:3000`
   - Web: `localhost:3000`
   - Real device: Configure `kLanIp` in `api_client.dart`

4. **All listed APIs are integrated and ready to use!**





