import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerProvider extends ChangeNotifier {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isMuted = false;
  bool _isDisposed = false;

  VideoPlayerController get controller => _controller!;
  bool get isInitialized => _isInitialized;
  bool get isMuted => _isMuted;

  /// 👇 Call this from the widget (once) instead of constructor
  Future<void> init() async {
    if (_isInitialized || _controller != null || _isDisposed) return;

    _controller = VideoPlayerController.asset(
      "assets/stock-footage-young-beautiful-girl-doctor-and-patient-having-medical-consultation-doing-thumb-up-gesture-at-clinic.mp4",
    );

    await _controller!.initialize();
    if (_isDisposed) return; // in case it was disposed mid-await

    _controller!
      ..setLooping(true)
      ..play();

    _isInitialized = true;
    notifyListeners();
  }

  void toggleSound() {
    if (_controller == null) return;
    _isMuted = !_isMuted;
    _controller!.setVolume(_isMuted ? 0 : 1);
    notifyListeners();
  }

  /// 👇 Control from outside (e.g. bottom nav tab change)
  void pause() {
    if (!_isInitialized || _controller == null) return;
    _controller!.pause();
  }

  void play() {
    if (!_isInitialized || _controller == null) return;
    _controller!.play();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller?.dispose();
    super.dispose();
  }
}
