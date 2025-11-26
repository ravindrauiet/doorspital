import 'package:door/features/chat/components/chat_body.dart';
import 'package:door/features/chat/components/chat_input_bar.dart';
import 'package:door/utils/images/images.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        elevation: 0.5,
        iconTheme: IconThemeData(color: AppColors.black),
        backgroundColor: AppColors.white,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(Images.doctor),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Dr.Bellamy Nich',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            splashRadius: 15,
            icon: const Icon(Icons.call_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
          IconButton(
            splashRadius: 15,
            icon: const Icon(Icons.videocam_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Images.chatBackground), // pattern bg
                    fit: BoxFit.cover,
                  ),
                ),
                child: const ChatBody(),
              ),
            ),
            ChatInputBar(),
          ],
        ),
      ),
    );
  }
}
