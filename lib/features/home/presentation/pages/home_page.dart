import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/system_ui_helper.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/user_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final fullName = user?.fullName ?? 'User';

    return AppScaffold(
      drawerHeaderColor: Colors.teal,
      title: fullName,
      appBarColor: Colors.teal,
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const AppText(
                      'Logout',
                      style: AppTextStyle.title,
                      color: Colors.black,
                    ),
                    content: const AppText(
                      'Are you sure you want to logout?',
                      style: AppTextStyle.body,
                      color: Colors.black,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const AppText(
                          'Cancel',
                          style: AppTextStyle.button,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const AppText(
                          'Logout',
                          style: AppTextStyle.button,
                        ),
                      ),
                    ],
                  ),
            );

            if (shouldLogout == true) {
              ref.read(authProvider.notifier).logout();
            }
          },
        ),
      ],
      systemUiOverlayStyle: SystemUIHelper.custom(
        statusBarColor: Colors.teal,
        iconBrightness: Brightness.light,
      ),
      body: Center(child: Text('Welcome to Progressify')),
    );
  }
}
