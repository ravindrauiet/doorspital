import 'package:door/features/chat/components/chat_bubble_doctor.dart';
import 'package:door/features/chat/components/chat_user_bubble.dart';
import 'package:flutter/material.dart';

class ChatBody extends StatelessWidget {
  const ChatBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      children: const [
        // user msg
        Align(
          alignment: Alignment.centerRight,
          child: ChatBubbleUser(
            text:
                'hello, doctor, i believe i have the coronavirus as i am experiencing mild symptoms, what do i do?',
            time: '10:13',
          ),
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: ChatBubbleDoctor(
            text:
                "I'm here for you, don’t worry.\nWhat symptoms are you experiencing?",
            time: '10:14',
          ),
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ChatBubbleUser(
            text: 'fever\ndry cough\ntiredness\nsore throat',
            time: '10:14',
          ),
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: ChatBubbleDoctor(
            text:
                'oh so sorry about that. do you have any underlying diseases?',
            time: '10:15',
          ),
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ChatBubbleUser(text: 'oh no', time: '10:16'),
        ),
        SizedBox(height: 4),
      ],
    );
  }
}
