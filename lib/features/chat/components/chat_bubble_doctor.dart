/* ---------------------- BUBBLES ---------------------- */

import 'package:flutter/material.dart';

class ChatBubbleDoctor extends StatelessWidget {
  final String text;
  final String time;

  const ChatBubbleDoctor({super.key, required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(
              16,
            ).copyWith(bottomLeft: const Radius.circular(4)),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}
