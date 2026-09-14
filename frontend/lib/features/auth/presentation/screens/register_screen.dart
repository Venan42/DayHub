import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/cyberpunk_background.dart';
import '../../../../shared/widgets/glow_card.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authProvider.notifier)
          .register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.error &&
          next.failure != null &&
          next.fieldErrors.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.failure!.message)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('DAYHUB'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: CyberpunkBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: GlowCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 28,
                            color: AppColors.yellow,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'CRIAR CONTA',
                            style: GoogleFonts.orbitron(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.jetBrainsMono(),
                        decoration: InputDecoration(
                          labelText: 'NOME',
                          errorText: authState.fieldErrors['name'],
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Informe o nome' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        style: GoogleFonts.jetBrainsMono(),
                        decoration: InputDecoration(
                          labelText: 'E-MAIL',
                          errorText: authState.fieldErrors['email'],
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Informe o e-mail' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        style: GoogleFonts.jetBrainsMono(),
                        decoration: InputDecoration(
                          labelText: 'SENHA',
                          errorText: authState.fieldErrors['password'],
                        ),
                        obscureText: true,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Informe a senha' : null,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 52,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              ),
                          child: isLoading
                              ? const Center(
                                  key: ValueKey('register_loading'),
                                  child: CircularProgressIndicator(),
                                )
                              : ElevatedButton(
                                  key: const ValueKey('register_button'),
                                  onPressed: _submit,
                                  child: Text(
                                    'CADASTRAR',
                                    style: GoogleFonts.orbitron(
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
