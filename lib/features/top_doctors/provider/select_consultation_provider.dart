import 'package:flutter/material.dart';

enum ConsultationType { messaging, audio, video, appointment }

class SelectConsultationProvider extends ChangeNotifier {
  ConsultationType? _selectedType;
  String? _selectedDuration;

  ConsultationType? get selectedType => _selectedType;
  String? get selectedDuration => _selectedDuration;

  void setType(ConsultationType? type) {
    _selectedType = type;
    notifyListeners();
  }

  void setDuration(String? duration) {
    _selectedDuration = duration;
    notifyListeners();
  }
}
