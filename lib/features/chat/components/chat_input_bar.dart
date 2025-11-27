import 'package:door/features/chat/provider/chat_media_picker_provider.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final bool isSending;
  final bool enabled;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.isSending = false,
    this.enabled = true,
  });

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

  void _handleSend() {
    final text = widget.controller.text.trim();
    if (text.isEmpty || widget.isSending || !widget.enabled) return;
    widget.onSend(text);
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
              onTap: widget.enabled ? _togglePopup : null,
              child: Icon(
                Icons.add,
                size: 30,
                color: widget.enabled
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.4),
              ),
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
                        controller: widget.controller,
                        enabled: widget.enabled,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: widget.enabled
                              ? 'Write a message...'
                              : 'Connecting...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: widget.isSending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: AppColors.primary,
                            ),
                      onPressed: widget.isSending ? null : _handleSend,
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
