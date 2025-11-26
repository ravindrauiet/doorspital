import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  XFile? _image;

  XFile? get image => _image;

  File? get imageFile => _image != null ? File(_image!.path) : null;

  bool get hasImage => _image != null;

  /// Pick image from gallery
  Future<void> pickFromGallery() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (picked != null) {
        _image = picked;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
    }
  }

  /// Pick image from camera
  Future<void> pickFromCamera() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (picked != null) {
        _image = picked;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking from camera: $e');
    }
  }

  void clearImage() {
    _image = null;
    notifyListeners();
  }
}
