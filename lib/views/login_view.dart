import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../utils/app_snackbar.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = auth.registerMode
        ? await auth.register(name, email, password)
        : await auth.signIn(email, password);

    if (!success && mounted) {
      _showMessage(auth.errorMessage ?? 'Ocorreu um erro. Tente novamente.');
    }
  }

  void _showMessage(String text) {
    showAppSnackBar(context, text, type: SnackType.error);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthController>();
    final loading = auth.isLoading;
    final registerMode = auth.registerMode;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      height: 76,
                      width: 76,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.location_city,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'UTFPR Solicitações',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    registerMode
                        ? 'Crie sua conta para começar'
                        : 'Entre para continuar',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (registerMode) ...[
                              TextFormField(
                                controller: _nameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Nome',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Informe seu nome.';
                                  }
                                  if (!RegExp(
                                    r'^[A-Za-zÀ-ÿ\s]+$',
                                  ).hasMatch(text)) {
                                    return 'O nome deve conter apenas letras.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) {
                                  return 'Informe o email.';
                                }
                                if (!RegExp(
                                  r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
                                ).hasMatch(text)) {
                                  return 'Email inválido.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Senha',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (value) {
                                final text = value ?? '';
                                if (text.isEmpty) {
                                  return 'Informe a senha.';
                                }
                                if (text.length < 6) {
                                  return 'A senha deve ter ao menos 6 caracteres.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: loading ? null : _submit,
                              child: loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(registerMode ? 'Registrar' : 'Entrar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: loading ? null : auth.toggleRegisterMode,
                    child: Text(
                      registerMode
                          ? 'Já tenho conta. Entrar'
                          : 'Criar uma nova conta',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
