import 'dart:ui';

import 'package:door/features/home/components/home_search_feild.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomeBanner extends StatelessWidget {
  final double height;
  final String backgroundImage;
  final String videoUrl;
  final String bookServiceLabel;
  final String giveServiceLabel;
  final String supportLabel;
  final String searchPlaceholder;
  final VoidCallback? onBookService;
  final VoidCallback? onGiveService;
  final VoidCallback? onSupport;
  final VoidCallback? onSearchTap;

  const HomeBanner({
    super.key,
    this.height = 360,
    this.backgroundImage = 'assets/images/Elderly Care copy.png',
    this.videoUrl = '',
    this.bookServiceLabel = 'Book a Service',
    this.giveServiceLabel = 'Give a Service',
    this.supportLabel = 'Support',
    this.searchPlaceholder = 'Search doctor, drugs, articles...',
    this.onBookService,
    this.onGiveService,
    this.onSupport,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: _BannerMedia(
                    backgroundImage: backgroundImage,
                    videoUrl: videoUrl,
                  ),
                ),
                Container(
                  color: Colors.black.withValues(alpha: 0.22),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 90,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: onBookService,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2F49D0),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2F49D0,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    bookServiceLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: onGiveService,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2F49D0),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2F49D0,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    giveServiceLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: onSupport,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              height: 50,
                              width: 160,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  supportLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SearchField(
              onTap: onSearchTap,
              hint: searchPlaceholder,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerMedia extends StatefulWidget {
  final String backgroundImage;
  final String videoUrl;

  const _BannerMedia({
    required this.backgroundImage,
    required this.videoUrl,
  });

  @override
  State<_BannerMedia> createState() => _BannerMediaState();
}

class _BannerMediaState extends State<_BannerMedia> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isMuted = true;
  bool _hasVideoError = false;

  @override
  void initState() {
    super.initState();
    _configureVideo();
  }

  @override
  void didUpdateWidget(covariant _BannerMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl.trim() != widget.videoUrl.trim()) {
      _configureVideo();
    }
  }

  Future<void> _configureVideo() async {
    final videoPath = widget.videoUrl.trim();
    final previousController = _controller;
    _controller = null;

    previousController?.dispose();

    if (mounted) {
      setState(() {
        _isInitialized = false;
        _isMuted = true;
        _hasVideoError = false;
      });
    }

    if (videoPath.isEmpty) return;

    final controller = _buildController(videoPath);
    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted || _controller != controller) {
        return;
      }

      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();

      if (mounted && _controller == controller) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (_) {
      final isCurrentController = _controller == controller;
      if (isCurrentController) {
        _controller = null;
        await controller.dispose();
      }
      if (mounted && isCurrentController) {
        setState(() {
          _hasVideoError = true;
          _isInitialized = false;
        });
      }
    }
  }

  VideoPlayerController _buildController(String videoPath) {
    if (videoPath.startsWith('http://') || videoPath.startsWith('https://')) {
      return VideoPlayerController.networkUrl(Uri.parse(videoPath));
    }

    return VideoPlayerController.asset(videoPath);
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;

    final shouldMute = !_isMuted;
    await controller.setVolume(shouldMute ? 0 : 1);

    if (mounted) {
      setState(() {
        _isMuted = shouldMute;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasVideo = _controller != null && !_hasVideoError;

    return Stack(
      fit: StackFit.expand,
      children: [
        _BannerImage(path: widget.backgroundImage),
        if (hasVideo && _isInitialized)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        if (hasVideo && !_isInitialized)
          const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        if (hasVideo && _isInitialized)
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: _toggleMute,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.28),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.32),
                      ),
                    ),
                    child: Icon(
                      _isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BannerImage extends StatelessWidget {
  final String path;

  const _BannerImage({required this.path});

  @override
  Widget build(BuildContext context) {
    final imagePath = path.trim();
    if (imagePath.isEmpty) {
      return const _BannerImageFallback();
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _BannerImageFallback(),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _BannerImageFallback(),
    );
  }
}

class _BannerImageFallback extends StatelessWidget {
  const _BannerImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white70,
        size: 34,
      ),
    );
  }
}
