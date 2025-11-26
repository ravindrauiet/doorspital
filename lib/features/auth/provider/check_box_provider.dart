import 'package:flutter/material.dart';

/// Provider model for Sign Up state management (no API)
class CheckBoxProvider extends ChangeNotifier {
  bool agreeTos = false;
  bool loading = false;

  void toggleAgree(bool? v) {
    agreeTos = v ?? false;
    notifyListeners();
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }
}
