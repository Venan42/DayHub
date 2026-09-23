import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('HOME')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Olá, ${user?.name.split(' ').first ?? ''}',
              style: GoogleFonts.orbitron(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'O que você quer fazer agora?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Grid de acesso rápido
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width >= 900 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _QuickActionCard(
                  icon: Icons.add_card_outlined,
                  label: 'Nova transação',
                  onTap: () => context.go('/finance'),
                ),
                _QuickActionCard(
                  icon: Icons.calculate_outlined,
                  label: 'Calculadora',
                  onTap: () => context.go('/finance'),
                ),
                _QuickActionCard(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                  onTap: () => context.go('/chat'),
                ),
                _QuickActionCard(
                  icon: Icons.person_outline,
                  label: 'Perfil',
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),

            const SizedBox(height: 32),
            Text('RESUMO DO MÊS', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 12),

            // Placeholder — substituído por dados reais na Fase 3 (módulo financeiro)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: isDark ? AppColors.yellowMuted : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.insights_outlined,
                    color: isDark ? AppColors.yellow : AppColors.darkText,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Resumo financeiro aparecerá aqui assim que o módulo estiver pronto.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isDark ? AppColors.yellowMuted : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isDark ? AppColors.yellow : AppColors.darkText,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}