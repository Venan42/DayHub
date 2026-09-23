import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/finance/presentation/screens/finance_placeholder_screen.dart';
import '../../features/modules/presentation/screens/modules_screen.dart';
import '../navigation/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: ValueNotifier(ref.watch(authProvider)),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (authState.status == AuthStatus.loading ||
          authState.status == AuthStatus.initial) {
        return null;
      }

      if (authState.status != AuthStatus.authenticated && !isLoggingIn) {
        return '/login';
      }

      if (authState.status == AuthStatus.authenticated && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(currentPath: state.uri.toString(), child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/finance',
            builder: (context, state) => const FinancePlaceholderScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/modules',
            builder: (context, state) => const ModulesScreen(),
          ),
        ],
      ),
    ],
  );
});