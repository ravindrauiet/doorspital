import 'dart:io';
import 'package:door/features/chat/provider/chat_media_picker_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ChatImagePreviewScreen extends StatelessWidget {
  final File image;

  const ChatImagePreviewScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<ChatMediaPickerProvider>().clear();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              context.read<ChatMediaPickerProvider>().clear();
              context.pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                // TODO: send image to chat
                Navigator.pop(context);
              },
              child: const Text(
                "Send",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        body: Center(child: Image.file(image)),
      ),
    );
  }
}
