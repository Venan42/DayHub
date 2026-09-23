import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_destination.dart';

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MÓDULOS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final module in allModules)
            Card(
              child: ListTile(
                leading: Icon(module.icon),
                title: Text(module.label),
                trailing: module.available
                    ? const Icon(Icons.chevron_right)
                    : const Text('Em breve'),
                enabled: module.available,
                onTap: module.available ? () => context.go(module.path) : null,
              ),
            ),
        ],
      ),
    );
  }
}