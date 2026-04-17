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
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          floatingActionButton: _WhatsAppFAB(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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


class _WhatsAppFAB extends StatefulWidget {
  const _WhatsAppFAB();

  @override
  State<_WhatsAppFAB> createState() => _WhatsAppFABState();
}

class _WhatsAppFABState extends State<_WhatsAppFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);
    _pulse = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    const phone = '917500958439';
    const message = 'Hello, I have a question about Doorspitals.';
    final encodedMsg = Uri.encodeComponent(message);

    // Try whatsapp:// deep link first (opens the app directly on mobile)
    final appUri = Uri.parse('whatsapp://send?phone=$phone&text=$encodedMsg');
    // Fallback: wa.me opens WhatsApp web on browser
    final webUri = Uri.parse('https://wa.me/$phone?text=$encodedMsg');

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openWhatsApp,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing ring
              Container(
                width: 56 * _pulse.value,
                height: 56 * _pulse.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF25D366)
                      .withOpacity(1.0 - (_pulse.value - 1.0)),
                ),
              ),
              // Main button
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF25D366).withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: _WhatsAppIcon(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Real WhatsApp brand icon from Font Awesome
class _WhatsAppIcon extends StatelessWidget {
  const _WhatsAppIcon();

  @override
  Widget build(BuildContext context) {
    return const FaIcon(
      FontAwesomeIcons.whatsapp,
      color: Colors.white,
      size: 30,
    );
  }
}

