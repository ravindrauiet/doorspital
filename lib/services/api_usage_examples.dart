// This file contains examples of how to use the API services
// You can reference this when integrating APIs into your screens

import 'package:door/services/auth_service.dart';
import 'package:door/services/doctor_service.dart';
import 'package:door/services/appointment_service.dart';
import 'package:door/services/models/auth_models.dart';
import 'package:door/services/models/doctor_models.dart';
import 'package:door/services/models/appointment_models.dart';
import 'dart:io';

class ApiUsageExamples {
  final _authService = AuthService();
  final _doctorService = DoctorService();
  final _appointmentService = AppointmentService();

  // ========== AUTH EXAMPLES ==========

  /// Example: Sign up a new user
  Future<void> signUpExample() async {
    final request = SignUpRequest(
      userName: 'John Doe',
      email: 'john@example.com',
      password: 'password123',
    );

    final response = await _authService.signUp(request);

    if (response.success) {
      print('Sign up successful: ${response.message}');
    } else {
      print('Sign up failed: ${response.message}');
      if (response.errors != null) {
        print('Errors: ${response.errors}');
      }
    }
  }

  /// Example: Sign in
  Future<void> signInExample() async {
    final request = SignInRequest(
      email: 'john@example.com',
      password: 'password123',
    );

    final response = await _authService.signIn(request);

    if (response.success && response.data != null) {
      print('Sign in successful!');
      print('Token: ${response.data!.token}');
      print('User: ${response.data!.user.userName}');
    } else {
      print('Sign in failed: ${response.message}');
    }
  }

  /// Example: Check if user is authenticated
  Future<void> checkAuthExample() async {
    final isAuth = await _authService.isAuthenticated();
    if (isAuth) {
      final user = await _authService.getCurrentUser();
      print('User is authenticated: ${user?.userName}');
    } else {
      print('User is not authenticated');
    }
  }

  // ========== DOCTOR EXAMPLES ==========

  /// Example: Get top doctors
  Future<void> getTopDoctorsExample() async {
    final response = await _doctorService.getTopDoctors(
      specialization: 'Cardiology',
      city: 'Mumbai',
      page: 1,
      limit: 10,
    );

    if (response.success && response.data != null) {
      print('Found ${response.data!.length} doctors');
      for (var doctor in response.data!) {
        print('Doctor: ${doctor.specialization} - ${doctor.city}');
      }
    } else {
      print('Failed to get doctors: ${response.message}');
    }
  }

  /// Example: Doctor sign up
  Future<void> doctorSignUpExample() async {
    final request = DoctorSignUpRequest(
      name: 'Dr. Jane Smith',
      email: 'jane@example.com',
      password: 'password123',
      specialization: 'Cardiology',
      experienceYears: 10,
      consultationFee: 500.0,
      city: 'Mumbai',
      timeZone: 'Asia/Kolkata',
    );

    final response = await _doctorService.doctorSignUp(request);

    if (response.success) {
      print('Doctor sign up successful!');
      print('Doctor ID: ${response.data?['doctorId']}');
    } else {
      print('Doctor sign up failed: ${response.message}');
    }
  }

  /// Example: Submit doctor verification
  Future<void> submitVerificationExample() async {
    final request = DoctorVerificationRequest(
      doctorId: '692414f641403b8be34f3bb8',
      fullName: 'Dr. Jane Smith',
      email: 'jane@example.com',
      phoneNumber: '+1234567890',
      medicalSpecialization: 'Cardiology',
      yearsOfExperience: 10,
      clinicHospitalName: 'City Hospital',
      clinicAddress: '123 Main St',
      state: 'Maharashtra',
      city: 'Mumbai',
      registrationNumber: 'REG123456',
      councilName: 'MCI',
      issueDate: '2015-01-01',
      documentType: 'Aadhaar Card',
    );

    // Note: In a real app, you would get these files from image picker
    final mbbsFile = File('/path/to/mbbs_certificate.pdf');
    final registrationFile = File('/path/to/registration_certificate.pdf');
    final governmentIdFile = File('/path/to/government_id.pdf');
    final selfieFile = File('/path/to/selfie.jpg');

    final response = await _doctorService.submitVerification(
      request,
      mbbsCertificate: mbbsFile,
      registrationCertificate: registrationFile,
      governmentId: governmentIdFile,
      selfie: selfieFile,
    );

    if (response.success) {
      print('Verification submitted successfully!');
    } else {
      print('Verification failed: ${response.message}');
    }
  }

  /// Example: Get verification status
  Future<void> getVerificationStatusExample() async {
    final doctorId = '692414f641403b8be34f3bb8';
    final response = await _doctorService.getVerificationStatus(doctorId);

    if (response.success && response.data != null) {
      print('Verification status: ${response.data!['status']}');
    } else {
      print('Failed to get status: ${response.message}');
    }
  }

  /// Example: Set doctor availability
  Future<void> setAvailabilityExample() async {
    final doctorId = '692414f641403b8be34f3bb8';
    final availability = [
      AvailabilityRule(
        dayOfWeek: 1, // Monday
        startTime: '09:00',
        endTime: '17:00',
        slotDurationMinutes: 15,
        isActive: true,
      ),
      AvailabilityRule(
        dayOfWeek: 2, // Tuesday
        startTime: '09:00',
        endTime: '17:00',
        slotDurationMinutes: 15,
        isActive: true,
      ),
    ];

    final request = SetAvailabilityRequest(availability: availability);
    final response = await _doctorService.setAvailability(doctorId, request);

    if (response.success) {
      print('Availability set successfully!');
    } else {
      print('Failed to set availability: ${response.message}');
    }
  }

  /// Example: Get availability schedule
  Future<void> getAvailabilityScheduleExample() async {
    final doctorId = '692414f641403b8be34f3bb8';
    final response = await _doctorService.getAvailabilitySchedule(
      doctorId,
      start: '2025-11-24T00:00:00Z',
      days: 7,
      tz: 'Asia/Kolkata',
    );

    if (response.success && response.data != null) {
      print('Availability for ${response.data!.days.length} days');
      for (var day in response.data!.days) {
        print('Date: ${day.date}, Slots: ${day.slots.length}');
      }
    } else {
      print('Failed to get availability: ${response.message}');
    }
  }

  // ========== APPOINTMENT EXAMPLES ==========

  /// Example: Search available doctors
  Future<void> searchAvailableDoctorsExample() async {
    final response = await _appointmentService.searchAvailableDoctors(
      date: '2025-11-24',
      specialization: 'Cardiology',
      city: 'Mumbai',
    );

    if (response.success && response.data != null) {
      print('Found ${response.data!.totalDoctors} doctors');
      for (var doctor in response.data!.doctors) {
        print('Doctor: ${doctor.doctor.specialization}');
        print('Available slots: ${doctor.availableSlots}');
      }
    } else {
      print('Failed to search: ${response.message}');
    }
  }

  /// Example: Book an appointment
  Future<void> bookAppointmentExample() async {
    final request = BookAppointmentRequest(
      doctorId: '692414f641403b8be34f3bb8',
      startTime: '2025-11-24T10:00:00Z', // ISO 8601 format
      reason: 'Regular checkup',
      mode: 'online',
    );

    final response = await _appointmentService.bookAppointment(request);

    if (response.success) {
      print('Appointment booked successfully!');
      print('Appointment ID: ${response.data?['appointmentId']}');
    } else {
      print('Failed to book: ${response.message}');
    }
  }

  /// Example: Get my appointments
  Future<void> getMyAppointmentsExample() async {
    final response = await _appointmentService.getMyAppointments(
      status: 'confirmed', // optional: 'pending', 'confirmed', 'cancelled', 'completed'
      page: 1,
      limit: 10,
    );

    if (response.success && response.data != null) {
      print('Found ${response.data!.length} appointments');
      for (var appointment in response.data!) {
        print('Appointment: ${appointment.startTime} - ${appointment.status}');
      }
    } else {
      print('Failed to get appointments: ${response.message}');
    }
  }

  /// Example: Cancel an appointment
  Future<void> cancelAppointmentExample() async {
    final appointmentId = 'appointment_id_here';
    final response = await _appointmentService.cancelAppointment(appointmentId);

    if (response.success) {
      print('Appointment cancelled successfully!');
    } else {
      print('Failed to cancel: ${response.message}');
    }
  }
}




