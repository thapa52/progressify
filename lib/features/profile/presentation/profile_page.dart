import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/system_ui_helper.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../auth/presentation/providers/user_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return AppScaffold(
      title: 'Profile',
      showDrawer: false,
      appBarColor: Colors.white,
      foregroundColor: Colors.black,
      systemUiOverlayStyle: SystemUIHelper.transparentLight,
      body: Column(
        children: [
          const SizedBox(height: 30),

          // ── Avatar ───────────────────────
          Center(
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  user?.avatar != null && user!.avatar.isNotEmpty
                      ? NetworkImage(user.avatar)
                      : null,
              child:
                  user?.avatar == null || user!.avatar.isEmpty
                      ? Icon(
                        Icons.person,
                        size: 55,
                        color: Colors.grey.shade400,
                      )
                      : null,
            ),
          ),
          const SizedBox(height: 16),

          // ── Full name ───────────────────────
          AppText(
            user?.fullName ?? 'User',
            style: AppTextStyle.heading,
            color: Colors.black,
          ),
          const SizedBox(height: 4),

          // ── Email ───────────────────────
          AppText(
            user?.email ?? '',
            style: AppTextStyle.body,
            color: Colors.grey,
          ),
          const SizedBox(height: 40),

          // ── Info Cards ──────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildInfoCard(
                  icon: Icons.person_outline,
                  label: 'First Name',
                  value: user?.firstName ?? '',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.person_outline,
                  label: 'Last Name',
                  value: user?.lastName ?? '',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user?.email ?? '',
                ),
              ],
            ),
          ),
          Spacer(),

          // ── Logout Button ───────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                  );

                  if (shouldLogout == true) {
                    ref.read(authProvider.notifier).logout();
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const AppText(
                  'Logout',
                  style: AppTextStyle.button,
                  color: Colors.red,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 24),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(label, style: AppTextStyle.caption, color: Colors.grey),
              SizedBox(height: 4),
              AppText(value, style: AppTextStyle.body, color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }
}
