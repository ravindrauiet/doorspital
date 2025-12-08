import 'package:door/features/articles/view/articles_list_screen.dart';
import 'package:door/features/home/view/home_screen.dart';
import 'package:door/features/home/view/services_screen.dart';
import 'package:door/features/profile/view/profile_screen.dart';
import 'package:door/features/pharmacy/view/pharmacy_home_screen.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:door/features/home/provider/bottom_navbar_provider.dart';
import 'package:door/features/home/provider/video_player_provider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  static const int videoTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavbarProvider>(
      builder: (context, provider, child) {
          final List<Widget> pages = [
            HomeScreen(),
            ServicesScreen(), // New Services Tab
            ArticlesListScreen(), // Health Tip Tab
            ProfileScreen(),
          ];

        return Scaffold(
          body: pages[provider.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view), 
                label: 'Services',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined),
                label: 'Health Tip',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                label: 'Profile',
              ),
            ],
            currentIndex: provider.currentIndex,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.darkGrey,
            type: BottomNavigationBarType.fixed,

            onTap: (index) {
              final videoProvider = context.read<VideoPlayerProvider>();

              if (provider.currentIndex == videoTabIndex &&
                  index != videoTabIndex) {
                videoProvider.pause();
              }

              if (provider.currentIndex != videoTabIndex &&
                  index == videoTabIndex) {
                videoProvider.play();
              }

              provider.updateIndex(index);
            },
          ),
        );
      },
    );
  }
}
