import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/request_detail_controller.dart';
import '../models/comment.dart';
import '../models/request.dart';
import '../services/auth_service.dart';
import '../services/request_service.dart';
import '../utils/app_snackbar.dart';
import '../utils/date_formatter.dart';

class RequestDetailView extends StatelessWidget {
  const RequestDetailView({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RequestDetailController>(
      create: (context) => RequestDetailController(
        requestService: context.read<RequestService>(),
        authService: context.read<AuthService>(),
        requestId: requestId,
      ),
      child: const _RequestDetailScaffold(),
    );
  }
}

class _RequestDetailScaffold extends StatelessWidget {
  const _RequestDetailScaffold();

  Future<void> _edit(BuildContext context, Request request) async {
    final controller = context.read<RequestDetailController>();

    final result = await showDialog<(String, String)>(
      context: context,
      builder: (dialogContext) => _EditDialog(
        initialTitle: request.title,
        initialDescription: request.description,
      ),
    );

    if (result != null) {
      final (title, description) = result;

      if (title.isNotEmpty && description.isNotEmpty) {
        await controller.update(title: title, description: description);
        if (context.mounted) {
          showAppSnackBar(
            context,
            'Solicitação atualizada.',
            type: SnackType.success,
          );
        }
      }
    }
  }

  Future<void> _delete(BuildContext context) async {
    final controller = context.read<RequestDetailController>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir solicitação'),
          content: const Text('Deseja realmente excluir esta solicitação?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Excluir',
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      controller.delete();

      if (context.mounted) {
        Navigator.of(context).pop();

        showAppSnackBar(
          context,
          'Solicitação excluída.',
          type: SnackType.success,
        );
      }
    }
  }

  Future<void> _addComment(BuildContext context) async {
    final controller = context.read<RequestDetailController>();

    final text = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _CommentDialog(),
    );

    if (text != null && text.isNotEmpty) {
      await controller.addComment(text);
      if (context.mounted) {
        showAppSnackBar(
          context,
          'Comentário adicionado.',
          type: SnackType.success,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RequestDetailController>();

    return Scaffold(
      body: _buildBody(context, controller),
      floatingActionButton: controller.request == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _addComment(context),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0D47A1),
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('Comentar'),
            ),
    );
  }

  Widget _buildBody(BuildContext context, RequestDetailController controller) {
    if (controller.isLoadingRequest) {
      return const Center(child: CircularProgressIndicator());
    }

    final request = controller.request;
    if (request == null) {
      return SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: BackButton(onPressed: () => Navigator.of(context).pop()),
            ),
            const Expanded(
              child: Center(child: Text('Solicitação não encontrada.')),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _Header(
          request: request,
          isOwner: controller.isOwner,
          onEdit: () => _edit(context, request),
          onDelete: () => _delete(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            child: _Content(request: request, comments: controller.comments),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.request,
    required this.isOwner,
    required this.onEdit,
    required this.onDelete,
  });

  final Request request;
  final bool isOwner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _image(context),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Color(0x8A000000), Color(0x00000000)],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back,
                    tooltip: 'Voltar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  if (isOwner)
                    Row(
                      children: [
                        _CircleButton(
                          icon: Icons.edit_outlined,
                          tooltip: 'Editar',
                          onPressed: onEdit,
                        ),
                        const SizedBox(width: 8),
                        _CircleButton(
                          icon: Icons.delete_outline,
                          tooltip: 'Excluir',
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(BuildContext context) {
    if (request.photoUrl.isEmpty) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          ),
        ),
        child: Center(
          child: Icon(Icons.campaign_outlined, size: 72, color: Colors.white),
        ),
      );
    }

    return Image.network(
      request.photoUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const ColoredBox(
              color: Color(0xFFE6E9F0),
              child: Center(child: CircularProgressIndicator()),
            ),
      errorBuilder: (context, error, stack) => const ColoredBox(
        color: Color(0xFFE6E9F0),
        child: Center(child: Icon(Icons.broken_image_outlined, size: 48)),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.request, required this.comments});

  final Request request;
  final List<Comment> comments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          request.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _Avatar(name: request.userName),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.userName.isEmpty ? 'Usuário' : request.userName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatDate(request.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          request.description,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 20),
        _LocationCard(latitude: request.latitude, longitude: request.longitude),
        const SizedBox(height: 28),
        Row(
          children: [
            Text(
              'Comentários',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            if (comments.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${comments.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (comments.isEmpty)
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Ainda não há comentários.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          )
        else
          ...comments.map((comment) => _CommentCard(comment: comment)),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E9F0)),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.location_on, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Localização',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${latitude.toStringAsFixed(6)}, '
                  '${longitude.toStringAsFixed(6)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E9F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(name: comment.userName),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.userName.isEmpty ? 'Usuário' : comment.userName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      formatDate(comment.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return CircleAvatar(
      radius: 18,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      child: Text(
        initial,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EditDialog extends StatefulWidget {
  const _EditDialog({
    required this.initialTitle,
    required this.initialDescription,
  });

  final String initialTitle;
  final String initialDescription;

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final TextEditingController _titleController = TextEditingController(
    text: widget.initialTitle,
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.initialDescription);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar solicitação'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Descrição'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop((
            _titleController.text.trim(),
            _descriptionController.text.trim(),
          )),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _CommentDialog extends StatefulWidget {
  const _CommentDialog();

  @override
  State<_CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<_CommentDialog> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo comentário'),
      content: TextField(
        controller: _commentController,
        maxLines: 3,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Comentário'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(_commentController.text.trim()),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
