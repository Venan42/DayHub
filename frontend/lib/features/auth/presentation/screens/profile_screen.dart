import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_provider.dart';
import '../providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PERFIL'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID', style: Theme.of(context).textTheme.labelMedium),
                  Text(user.id),
                  const SizedBox(height: 16),
                  Text('NOME', style: Theme.of(context).textTheme.labelMedium),
                  Text(user.name),
                  const SizedBox(height: 16),
                  Text(
                    'E-MAIL',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(user.email),
                ],
              ),
            ),
    );
  }
}
