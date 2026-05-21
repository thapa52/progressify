import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/system_ui_helper.dart';
import '../../../../core/widgets/app_scaffold.dart';
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
      systemUiOverlayStyle: SystemUIHelper.custom(
        statusBarColor: Colors.teal,
        iconBrightness: Brightness.dark,
      ),
      body: Center(child: Text('Welcome to Video Journal')),
    );
  }
}
