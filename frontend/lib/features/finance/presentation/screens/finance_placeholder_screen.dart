import 'package:flutter/material.dart';

class FinancePlaceholderScreen extends StatelessWidget {
  const FinancePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FINANCEIRO')),
      body: const Center(child: Text('Módulo financeiro em construção.')),
    );
  }
}