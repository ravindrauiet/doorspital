import 'package:door/features/components/custom_appbar.dart';
import 'package:door/main.dart';
import 'package:door/utils/images/images.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Notifications"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Image.asset(Images.noData, height: screenHeight / 2)],
      ),
    );
  }
}
