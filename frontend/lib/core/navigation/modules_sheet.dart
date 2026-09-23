import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_destination.dart';

class ModulesSheet extends StatelessWidget {
  const ModulesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('MÓDULOS', style: Theme.of(context).textTheme.labelMedium),
            ),
            for (final module in allModules)
              ListTile(
                leading: Icon(module.icon),
                title: Text(module.label),
                trailing: module.available ? null : const Text('Em breve'),
                enabled: module.available,
                onTap: module.available
                    ? () {
                        Navigator.of(context).pop();
                        context.go(module.path);
                      }
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}