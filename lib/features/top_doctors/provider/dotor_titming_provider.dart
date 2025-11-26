import 'package:door/features/top_doctors/provider/doctor_availability_provider.dart';
import 'package:flutter/material.dart';

/// Provider state (Legacy provider - kept for backward compatibility)
class DotorTitmingProvider extends ChangeNotifier {
  // dates for the row (Mon–Sat)
  final List<Day> days = const [
    Day(label: 'Mon', day: '21', date: ''),
    Day(label: 'Tue', day: '22', date: ''),
    Day(label: 'Wed', day: '23', date: ''),
    Day(label: 'Thu', day: '24', date: ''),
    Day(label: 'Fri', day: '25', date: ''),
    Day(label: 'Sat', day: '26', date: ''),
  ];

  // times in the grid
  final List<String> times = const [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '07:00 PM',
    '08:00 PM',
  ];

  int selectedDayIndex = 2; // default "Wed 23" like the mock
  String? selectedTime = '02:00 PM';

  void selectDay(int index) {
    selectedDayIndex = index;
    notifyListeners();
  }

  void selectTime(String time) {
    selectedTime = time;
    notifyListeners();
  }
}
