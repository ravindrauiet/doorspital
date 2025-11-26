import 'package:door/services/models/doctor_models.dart';
import 'package:flutter/material.dart';

class DoctorAvailabilityProvider extends ChangeNotifier {
  List<DayAvailability> _availabilityDays = [];
  List<Day> _days = [];
  List<TimeSlot> _availableSlots = [];
  int _selectedDayIndex = 0;
  TimeSlot? _selectedSlot;
  bool _loading = false;
  String? _error;

  List<DayAvailability> get availabilityDays => _availabilityDays;
  List<Day> get days => _days;
  List<TimeSlot> get availableSlots => _availableSlots;
  int get selectedDayIndex => _selectedDayIndex;
  TimeSlot? get selectedSlot => _selectedSlot;
  bool get loading => _loading;
  String? get error => _error;

  void setAvailability(AvailabilityResponse availability) {
    _availabilityDays = availability.days;
    _updateDaysFromAvailability();
    _updateSlotsForSelectedDay();
    notifyListeners();
  }

  void _updateDaysFromAvailability() {
    _days = _availabilityDays.map((dayData) {
      final date = DateTime.parse(dayData.date);
      final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      final dayName = dayNames[date.weekday % 7];
      final dayNumber = date.day.toString();
      final availableSlots = dayData.slots.where((slot) => slot.available).toList();
      final hasSlots = availableSlots.isNotEmpty;
      
      return Day(
        label: dayName,
        day: dayNumber,
        date: dayData.date,
        hasAvailableSlots: hasSlots,
        availableSlotsCount: availableSlots.length,
      );
    }).toList();
    
    // Auto-select the first day with available slots
    int firstDayWithSlots = _days.indexWhere((day) => day.hasAvailableSlots);
    if (firstDayWithSlots != -1) {
      _selectedDayIndex = firstDayWithSlots;
    } else if (_days.isNotEmpty) {
      _selectedDayIndex = 0;
    } else if (_selectedDayIndex >= _days.length) {
      _selectedDayIndex = 0;
    }
  }

  void _updateSlotsForSelectedDay() {
    if (_selectedDayIndex < _availabilityDays.length) {
      final selectedDay = _availabilityDays[_selectedDayIndex];
      _availableSlots = selectedDay.slots.where((slot) => slot.available).toList();
    } else {
      _availableSlots = [];
    }
  }

  void selectDay(int index) {
    if (index >= 0 && index < _days.length) {
      _selectedDayIndex = index;
      _selectedSlot = null; // Reset selected slot when day changes
      _updateSlotsForSelectedDay();
      notifyListeners();
    }
  }

  void selectSlot(TimeSlot slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Extended Day class to include date
class Day {
  final String label;
  final String day;
  final String date; // ISO date string
  final bool hasAvailableSlots; // Whether this day has available slots
  final int availableSlotsCount; // Number of available slots
  const Day({
    required this.label,
    required this.day,
    required this.date,
    this.hasAvailableSlots = false,
    this.availableSlotsCount = 0,
  });
}

