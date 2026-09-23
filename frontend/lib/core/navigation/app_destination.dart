import 'package:flutter/material.dart';

class AppDestination {
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const AppDestination({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

const primaryDestinations = <AppDestination>[
  AppDestination(
    path: '/dashboard',
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  AppDestination(
    path: '/chat',
    label: 'Chat',
    icon: Icons.chat_bubble_outline,
    selectedIcon: Icons.chat_bubble,
  ),
  AppDestination(
    path: '/finance',
    label: 'Financeiro',
    icon: Icons.account_balance_wallet_outlined,
    selectedIcon: Icons.account_balance_wallet,
  ),
  AppDestination(
    path: '/profile',
    label: 'Perfil',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
];

class ModuleEntry {
  final String path;
  final String label;
  final IconData icon;
  final bool available;

  const ModuleEntry({
    required this.path,
    required this.label,
    required this.icon,
    this.available = true,
  });
}

const allModules = <ModuleEntry>[
  ModuleEntry(
    path: '/finance',
    label: 'Financeiro',
    icon: Icons.account_balance_wallet_outlined,
  ),
  ModuleEntry(
    path: '/media',
    label: 'Mídia',
    icon: Icons.perm_media_outlined,
    available: false,
  ),
  ModuleEntry(
    path: '/tasks',
    label: 'Tarefas',
    icon: Icons.checklist_outlined,
    available: false,
  ),
];
