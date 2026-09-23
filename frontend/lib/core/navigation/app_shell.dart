import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import 'app_destination.dart';
import 'modules_sheet.dart';

const _kWideBreakpoint = 800.0;

class AppShell extends ConsumerWidget {
  final Widget child;
  final String currentPath;

  const AppShell({super.key, required this.child, required this.currentPath});

  int get _selectedIndex {
    final index = primaryDestinations.indexWhere(
      (d) => currentPath.startsWith(d.path),
    );
    return index;
  }

  void _onPrimarySelected(BuildContext context, int index) {
    context.go(primaryDestinations[index].path);
  }

  void _openModulesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => const ModulesSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width >= _kWideBreakpoint;
    final themeMode = ref.watch(themeModeProvider);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: MediaQuery.of(context).size.width >= 1100,
              selectedIndex: _selectedIndex < 0 ? null : _selectedIndex,
              onDestinationSelected: (index) =>
                  _onPrimarySelected(context, index),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    const Icon(Icons.bolt, size: 28, color: AppColors.yellow),
                    const SizedBox(height: 4),
                    Text(
                      'DAYHUB',
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(letterSpacing: 2),
                    ),
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(
                      icon: Icon(
                        themeMode == ThemeMode.dark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                      onPressed: () =>
                          ref.read(themeModeProvider.notifier).toggle(),
                    ),
                  ),
                ),
              ),
              destinations: [
                for (final d in primaryDestinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            // Item "Módulos" fora do NavigationRail.destinations pra não
            // competir com o índice selecionado dos 4 principais.
            Expanded(child: child),
          ],
        ),
        floatingActionButton: currentPath == '/modules'
            ? null
            : FloatingActionButton.small(
                heroTag: 'modules_fab',
                tooltip: 'Todos os módulos',
                onPressed: () => context.go('/modules'),
                child: const Icon(Icons.apps),
              ),
      );
    }

    // Mobile
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex < 0
            ? primaryDestinations.length
            : _selectedIndex,
        onDestinationSelected: (index) {
          if (index == primaryDestinations.length) {
            _openModulesSheet(context);
            return;
          }
          _onPrimarySelected(context, index);
        },
        destinations: [
          for (final d in primaryDestinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
          const NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'Mais',
          ),
        ],
      ),
    );
  }
}
