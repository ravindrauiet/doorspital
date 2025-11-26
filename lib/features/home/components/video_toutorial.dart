import 'package:door/features/home/provider/video_player_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

class VideoToutorial extends StatefulWidget {
  const VideoToutorial({super.key});

  @override
  State<VideoToutorial> createState() => _VideoToutorialState();
}

class _VideoToutorialState extends State<VideoToutorial> {
  @override
  void initState() {
    super.initState();
    // wait for context to be ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoPlayerProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = context.watch<VideoPlayerProvider>();

    if (!videoProvider.isInitialized) {
      return _buildShimmerPlaceholder();
    }

    final controller = videoProvider.controller;

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
        ),

        // 🔊 Sound button
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () => videoProvider.toggleSound(),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black54,
              child: Icon(
                videoProvider.isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
