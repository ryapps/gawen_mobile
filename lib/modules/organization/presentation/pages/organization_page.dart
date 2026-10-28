import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gawen_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../home/widgets/main_navigation.dart';
import '../bloc/organization_bloc.dart';

class OrganizationPage extends StatefulWidget {
  const OrganizationPage({super.key});

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  @override
  void initState() {
    super.initState();
    final organizationId = context.read<AuthBloc>().state.organizationId;
    if (organizationId != null) {
      context.read<OrganizationBloc>().add(
        OrganizationLoadRequested(organizationId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    return BlocBuilder<OrganizationBloc, OrganizationState>(
      builder: (context, state) {
        final organization = state.organization;
        return Scaffold(
          appBar: AppBar(title: const Text('Informasi Usaha')),
          body: SafeArea(
            child:
                state.status == OrganizationStatus.loading &&
                    organization == null
                ? const Center(child: CircularProgressIndicator())
                : state.status == OrganizationStatus.failure &&
                      organization == null
                ? _LoadFailure(
                    message: state.message ?? 'Informasi usaha gagal dimuat.',
                    onRetry: () {
                      final id = auth.organizationId;
                      if (id != null) {
                        context.read<OrganizationBloc>().add(
                          OrganizationLoadRequested(id),
                        );
                      }
                    },
                  )
                : ListView(
                    padding: const EdgeInsets.all(22),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: GawenColors.border),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.storefront_outlined,
                              color: GawenColors.primary,
                              size: 30,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              organization?.name ?? 'Informasi usaha',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(
                              label: 'Zona waktu',
                              value: organization?.timezone ?? '-',
                            ),
                            const SizedBox(height: 10),
                            _InfoRow(
                              label: 'Jumlah anggota',
                              value:
                                  organization?.memberCount?.toString() ?? '-',
                            ),
                          ],
                        ),
                      ),
                      if (state.status == OrganizationStatus.failure &&
                          state.message != null)
                        RequestError(message: state.message!),
                      if (auth.isOwner &&
                          auth.organizationId != null &&
                          organization != null) ...[
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: () =>
                              context.push(AppRoutes.editOrganization),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Informasi Usaha'),
                        ),
                      ],
                    ],
                  ),
          ),
          bottomNavigationBar: MainNavigation(
            isOwner: auth.isOwner,
            currentPath: AppRoutes.more,
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(color: GawenColors.muted)),
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RequestError(message: message),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    ),
  );
}
