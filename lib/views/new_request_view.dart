import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/new_request_controller.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/request_service.dart';
import '../utils/app_snackbar.dart';

class NewRequestView extends StatelessWidget {
  const NewRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NewRequestController>(
      create: (context) => NewRequestController(
        requestService: context.read<RequestService>(),
        authService: context.read<AuthService>(),
        locationService: context.read<LocationService>(),
      ),
      child: const _NewRequestScaffold(),
    );
  }
}

class _NewRequestScaffold extends StatefulWidget {
  const _NewRequestScaffold();

  @override
  State<_NewRequestScaffold> createState() => _NewRequestScaffoldState();
}

class _NewRequestScaffoldState extends State<_NewRequestScaffold> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<NewRequestController>();
    final success = await controller.submit(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      showAppSnackBar(
        context,
        'Solicitação cadastrada com sucesso.',
        type: SnackType.success,
      );
      Navigator.of(context).pop();
    } else {
      showAppSnackBar(
        context,
        controller.errorMessage ?? 'Não foi possível cadastrar.',
        type: controller.photo == null ? SnackType.warning : SnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<NewRequestController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(),
        title: const Text('Nova Solicitação'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton(
              onPressed: controller.isSaving ? null : _submit,
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('Cadastrar'),
            ),
          ),
        ],
      ),
      body: controller.isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      hintText: 'Ex.: Buraco na quadra esportiva',
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Informe o título.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      alignLabelWithHint: true,
                      hintText: 'Descreva o ocorrido com detalhes',
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Informe a descrição.'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Foto do ocorrido',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (controller.photo != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        controller.photo!,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton.icon(
                    onPressed: controller.takePhoto,
                    icon: const Icon(Icons.photo_camera),
                    label: Text(
                      controller.photo == null ? 'Tirar Foto' : 'Trocar Foto',
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
