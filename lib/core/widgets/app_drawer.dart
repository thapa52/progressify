import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/user_provider.dart';
import '../router/app_router.dart';
import 'app_text.dart';

class AppDrawer extends ConsumerWidget {
  final Color headerColor;
  const AppDrawer({super.key, required this.headerColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final fullName = user?.fullName ?? 'User';
    final email = user?.email ?? '';
    final size = MediaQuery.of(context).size;

    return Drawer(
      backgroundColor: headerColor,
      width: MediaQuery.of(context).size.width,
      child: SafeArea(
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 35,
                    child: Icon(Icons.person, size: 30, color: headerColor),
                  ),
                  const SizedBox(height: 10),
                  AppText(
                    fullName,
                    style: AppTextStyle.title,
                    color: Colors.white,
                  ),
                  AppText(email, style: AppTextStyle.body, color: Colors.white),
                ],
              ),
            ),
            Divider(color: Colors.white),
            _buildMenuItem(
              size: size,
              icon: Icons.home,
              label: 'Home',
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.home);
              },
            ),
            _buildMenuItem(
              size: size,
              icon: Icons.account_circle,
              label: 'Profile',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.profile);
              },
            ),
            _buildMenuItem(
              size: size,
              icon: Icons.play_circle_fill_rounded,
              label: 'My Quest',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildMenuItem(
              size: size,
              icon: Icons.add_circle,
              label: 'Browse Quests',
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required Size size,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: size.width * 0.7,
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                SizedBox(width: 12),
                AppText(label, style: AppTextStyle.label, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
