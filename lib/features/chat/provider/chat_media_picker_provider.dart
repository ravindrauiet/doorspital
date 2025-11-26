import 'dart:io';
import 'package:door/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

enum ChatMediaSource { camera, gallery }

class ChatMediaPickerProvider extends ChangeNotifier {
  ChatMediaSource? _selectedSource;
  File? _pickedImage;

  ChatMediaSource? get selectedSource => _selectedSource;
  File? get pickedImage => _pickedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickFromCamera({required BuildContext context}) async {
    _selectedSource = ChatMediaSource.camera;
    final XFile? file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      _pickedImage = File(file.path);
      notifyListeners();
      context.pushNamed(
        RouteConstants.chatImagePreviewScreen,
        extra: _pickedImage,
      );
    }
  }

  Future<void> pickFromGallery({required BuildContext context}) async {
    _selectedSource = ChatMediaSource.gallery;
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      _pickedImage = File(file.path);
      notifyListeners();
      context.pushNamed(
        RouteConstants.chatImagePreviewScreen,
        extra: _pickedImage,
      );
    }
  }

  void clear() {
    _selectedSource = null;
    _pickedImage = null;
    notifyListeners();
  }
}
