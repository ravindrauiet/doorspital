import 'package:door/utils/images/images.dart';
import 'package:door/features/pharmacy/view/my_orders_page.dart';
import 'package:door/welcome_screen.dart';
import 'package:flutter/material.dart';
// import 'api.dart'; // uncomment if using SessionClient for backend logout

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    this.name = 'Ruchita',
    this.photoAsset = Images.ruchita,
    this.showBottomNav = false, // default false when embedded in parent
  });

  final String name;
  final String photoAsset;
  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(photoAsset),
                    backgroundColor: const Color(0xFFF1F5F9),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            const Divider(height: 0),

            // Menu
            _MenuTile(
              label: 'My Orders',
              icon: Icons.shopping_bag_outlined,
              tint: const Color(0xFF84E1C3),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyOrdersPage(),
                  ),
                );
              },
            ),
            _MenuTile(
              label: 'My Saved',
              icon: Icons.bookmark_border,
              tint: const Color(0xFF84E1C3),
              tintedIcon: true,
              onTap: () {
                // TODO: navigate to Saved
              },
            ),
            _MenuTile(
              label: 'Appointment',
              icon: Icons.event_note_outlined,
              tint: const Color(0xFF84E1C3),
              onTap: () {
                // TODO: navigate to Appointments
              },
            ),
            _MenuTile(
              label: 'FAQs',
              icon: Icons.help_outline_rounded,
              tint: const Color(0xFF84E1C3),
              onTap: () {
                // TODO: navigate to FAQs
              },
            ),

            // Logout (red)
            _MenuTile(
              label: 'Logout',
              icon: Icons.logout_rounded,
              tint: const Color(0xFFFFE4E9),
              foreground: const Color(0xFFE11D48),
              labelColor: const Color(0xFFE11D48),
              onTap: () async {
                // Optional: clear backend session
                // final api = SessionClient();
                // await api.get('/auth/logout');

                // Navigate to welcome / onboarding page & clear stack
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Menu item row with icon + label + chevron
class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.label,
    required this.icon,
    required this.tint,
    this.onTap,
    this.tintedIcon = false,
    this.foreground,
    this.labelColor,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final Color? foreground;
  final Color? labelColor;
  final VoidCallback? onTap;
  final bool tintedIcon;

  @override
  Widget build(BuildContext context) {
    final row = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: tint.withOpacity(0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 20,
                color:
                    foreground ??
                    (tintedIcon ? const Color(0xFF18C2A5) : Colors.black87),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: labelColor ?? Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black26),
          ],
        ),
      ),
    );

    return Column(children: [row, const Divider(height: 0)]);
  }
}
