import 'package:flutter/material.dart';

class ComplaintTextProvider extends ChangeNotifier {
  final TextEditingController controller = TextEditingController();

  int get length => controller.text.length;

  ComplaintTextProvider() {
    controller.addListener(notifyListeners); // rebuild listeners on each change
  }

  @override
  void dispose() {
    controller.removeListener(notifyListeners);
    controller.dispose();
    super.dispose();
  }
}
