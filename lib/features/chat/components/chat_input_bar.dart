import 'package:door/routes/route_constants.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:door/features/chat/provider/chat_media_picker_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final GlobalKey _menuKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removePopup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            InkWell(
              key: _menuKey,
              onTap: _togglePopup,
              child: const Icon(Icons.add, size: 30, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Write a message...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.mic_none_rounded,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePopup() {
    if (_overlayEntry == null) {
      _showPopup();
    } else {
      _removePopup();
    }
  }

  void _showPopup() {
    final RenderBox button =
        _menuKey.currentContext!.findRenderObject() as RenderBox;
    final Offset buttonOffset = button.localToGlobal(Offset.zero);
    final overlay = Overlay.of(context);

    const double bottomSpacing = 70;

    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            // tap outside to close
            Positioned.fill(
              child: GestureDetector(
                onTap: _removePopup,
                behavior: HitTestBehavior.translucent,
              ),
            ),

            Positioned(
              left: buttonOffset.dx,
              // keep it near the button but with space from bottom
              bottom: bottomSpacing,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  width: 160, // popup width

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildItem(
                        icon: Icons.camera_alt_outlined,
                        text: 'Camera',
                        onTap: () {
                          final picker = context
                              .read<ChatMediaPickerProvider>();

                          picker.pickFromCamera(context: context);

                          final image = picker.pickedImage;
                          if (image != null) {
                            if (mounted) {
                              context.pushNamed(
                                RouteConstants.chatImagePreviewScreen,
                                extra: image,
                              );
                            }
                          }
                          _removePopup();
                        },
                      ),
                      _buildItem(
                        icon: Icons.photo_library_outlined,
                        text: 'Gallery',
                        onTap: () {
                          final picker = context
                              .read<ChatMediaPickerProvider>();
                          final image = picker.pickedImage;
                          if (image != null) {
                            if (mounted) {
                              context.pushNamed(
                                RouteConstants.chatImagePreviewScreen,
                                extra: image,
                              );
                            }
                          }
                          picker.pickFromGallery(context: context);
                          _removePopup();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  Widget _buildItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _removePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
