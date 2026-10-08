import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/request_list_controller.dart';
import '../models/request.dart';
import '../services/request_service.dart';
import '../utils/date_formatter.dart';
import 'new_request_view.dart';
import 'request_detail_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RequestListController>(
      create: (context) =>
          RequestListController(context.read<RequestService>()),
      child: const _HomeScaffold(),
    );
  }
}

class _HomeScaffold extends StatelessWidget {
  const _HomeScaffold();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RequestListController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitações Públicas'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: context.read<AuthController>().signOut,
          ),
          IconButton(
            tooltip: 'Adicionar',
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const NewRequestView()));
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(context, controller),
    );
  }

  Widget _buildBody(BuildContext context, RequestListController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasError) {
      return const _Message(
        icon: Icons.cloud_off_outlined,
        text: 'Erro ao carregar as solicitações.',
      );
    }

    final requests = controller.requests;

    if (requests.isEmpty) {
      return const _Message(
        icon: Icons.inbox_outlined,
        text: 'Ainda não há solicitações realizadas',
        hint: 'Toque em + para criar a primeira.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _RequestTile(request: requests[index]),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request});

  final Request request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RequestDetailView(requestId: request.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.campaign_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
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
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.hint});

  final IconData icon;
  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: 6),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
