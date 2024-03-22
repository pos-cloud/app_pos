import 'package:app_pos/pages/home/home_screen.dart';
import 'package:app_pos/pages/home/views/keyboard_screen.dart';
import 'package:app_pos/pages/receipts/receipts_screen.dart';
import 'package:app_pos/screens/login_screen.dart';

import 'package:go_router/go_router.dart';

final applicationRouter = GoRouter(
  initialLocation: LoginScreen.path,
  routes: [
    GoRoute(
      path: LoginScreen.path,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: HomeScreen.path,
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: ReceiptsScreen.path,
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        child: const ReceiptsScreen(),
      ),
    ),
    GoRoute(
      path: KeyboardScreen.path,
      builder: (context, state) => const KeyboardScreen(),
    ),
  ],
);
