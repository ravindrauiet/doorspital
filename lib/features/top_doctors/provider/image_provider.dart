import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickProvider extends ChangeNotifier {
  final List<XFile> _images = [];
  static const int maxImages = 6; // limit

  List<XFile> get images => _images;

  List<File> get imageFiles => _images.map((x) => File(x.path)).toList();

  Future pickFromGallery() async {
    // If already at limit, do not add
    if (_images.length >= maxImages) {
      notifyListeners();
      return;
    }

    final picked = await ImagePicker().pickMultiImage();

    if (picked.isNotEmpty) {
      // Allow adding only until maxImages
      int availableSlots = maxImages - _images.length;

      _images.addAll(picked.take(availableSlots));

      notifyListeners();
    }
  }

  Future pickFromCamera() async {
    // Stop camera adding if limit reached
    if (_images.length >= maxImages) {
      notifyListeners();
      return;
    }

    final picked = await ImagePicker().pickImage(source: ImageSource.camera);

    if (picked != null) {
      _images.add(picked);
      notifyListeners();
    }
  }

  void removeImage(int index) {
    _images.removeAt(index);
    notifyListeners();
  }
}
