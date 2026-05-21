import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';

// Route paths as constants
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/';
}

// Router provider
final appRouteProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,

    // This runs before every navigation
    // It checks if the user is allowed to see the page
    redirect: (context, state) {
      final isOnLoginPage = state.matchedLocation == AppRoutes.login;

      // If NOT logged in and NOT on login page → go to login
      if (!isLoggedIn && !isOnLoginPage) {
        return AppRoutes.login;
      }

      // If logged in and ON login page → go to home
      if (isLoggedIn && isOnLoginPage) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (context, state) => LoginPage()),
      GoRoute(path: AppRoutes.home, builder: (context, state) => HomePage()),
    ],
  );
});
