import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_bar.dart';
import 'package:frontend/core/widgets/gawen_empty_state.dart';
import 'package:frontend/core/widgets/gawen_loading.dart';
import 'package:frontend/core/widgets/gawen_page.dart';
import 'package:frontend/core/widgets/gawen_toast.dart';
import 'package:frontend/core/widgets/gawen_button.dart';
import 'package:frontend/core/widgets/main_navigation.dart';
import 'package:frontend/core/widgets/request_error.dart';
import 'package:frontend/core/widgets/gawen_text.dart';
import 'package:frontend/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/modules/employee/domain/entities/employee_entity.dart';
import 'package:frontend/modules/employee/presentation/bloc/employee_bloc.dart';
import 'package:frontend/modules/employee/presentation/widgets/employees_page_widget.dart';
import 'package:frontend/modules/invitation/presentation/bloc/invitation_bloc.dart';
import 'package:go_router/go_router.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;
  EmployeeEmploymentStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(const ManagedEmployeesRequested());
    _loadJoinRequests();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchFocusNode.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _loadEmployees();
    });
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 300) {
      context.read<EmployeeBloc>().add(
        const ManagedEmployeesLoadMoreRequested(),
      );
    }
  }

  void _loadEmployees({
    EmployeeEmploymentStatus? status,
    bool setFilter = false,
  }) {
    if (setFilter) _filterStatus = status;
    context.read<EmployeeBloc>().add(
      ManagedEmployeesRequested(
        search: _searchController.text.trim(),
        status: _filterStatus,
      ),
    );
  }

  Future<void> _refresh() async {
    final employeeBloc = context.read<EmployeeBloc>();
    final employeeLoaded = employeeBloc.stream.firstWhere(
      (state) =>
          state.listStatus == EmployeeListStatus.ready ||
          state.listStatus == EmployeeListStatus.failure,
    );
    final organizationId = context.read<AuthBloc>().state.organizationId;
    final invitationBloc = context.read<InvitationBloc>();
    final requestsLoaded = organizationId == null
        ? null
        : invitationBloc.stream.firstWhere(
            (state) =>
                state.ownerRequestsStatus == OwnerJoinRequestsStatus.ready ||
                state.ownerRequestsStatus == OwnerJoinRequestsStatus.failure,
          );
    _loadEmployees();
    _loadJoinRequests();
    await employeeLoaded;
    if (requestsLoaded != null) await requestsLoaded;
  }

  void _reload() => _loadEmployees();

  void _loadJoinRequests() {
    final organizationId = context.read<AuthBloc>().state.organizationId;
    if (organizationId != null) {
      context.read<InvitationBloc>().add(
        OwnerJoinRequestsRefreshRequested(organizationId),
      );
    }
  }

  void _handleFilterChanged(EmployeeEmploymentStatus? status) {
    _loadEmployees(status: status, setFilter: true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (!auth.isOwner) return const EmployeeAccessDenied();
    return BlocConsumer<EmployeeBloc, EmployeeState>(
      listenWhen: (previous, current) =>
          previous.message != current.message && current.message != null,
      listener: (context, state) {
        if (state.status == EmployeeStatus.failure) {
          GawenToast.error(context, message: state.message!);
        } else {
          GawenToast.success(context, message: state.message!);
        }
      },
      builder: (context, state) {
        final employees = state.managedEmployees;
        final activeCount = employees
            .where(
              (employee) => employee.status == EmployeeEmploymentStatus.active,
            )
            .length;
        final initialLoading =
            state.listStatus == EmployeeListStatus.loading && employees.isEmpty;
        return GawenPage(
          appBar: GawenAppBar(
            title: 'Karyawan',
            subtitle: '${employees.length} anggota • $activeCount aktif',
            action: TextButton.icon(
              onPressed: () => context.push(AppRoutes.inviteEmployee),
              icon: const Icon(CupertinoIcons.person_add),
              label: const Text('Undang'),
              style: TextButton.styleFrom(
                foregroundColor: GawenColors.primarySoft,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
                backgroundColor: GawenColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          padding: EdgeInsets.zero,
          scrollable: false,
          bottomNavigationBar: MainNavigation(
            isOwner: true,
            currentPath: AppRoutes.employees,
          ),
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: GawenSpacing.pageHorizontal,
                vertical: GawenSpacing.pageVertical,
              ),
              children: [
                BlocBuilder<InvitationBloc, InvitationState>(
                  builder: (context, invitationState) => RequestJoinButton(
                    onPressed: () => context.push(AppRoutes.ownerJoinRequests),
                    personLength: invitationState.ownerRequests.length,
                    loading:
                        invitationState.ownerRequestsStatus ==
                            OwnerJoinRequestsStatus.initial ||
                        invitationState.ownerRequestsStatus ==
                            OwnerJoinRequestsStatus.loading,
                    failed:
                        invitationState.ownerRequestsStatus ==
                        OwnerJoinRequestsStatus.failure,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Cari nama karyawan',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  children: [
                    StatusFilterChip(
                      label: 'Semua',
                      status: null,
                      filterStatus: _filterStatus,
                      onFilterChanged: _handleFilterChanged,
                    ),
                    StatusFilterChip(
                      label: 'Aktif',
                      status: EmployeeEmploymentStatus.active,
                      filterStatus: _filterStatus,
                      onFilterChanged: _handleFilterChanged,
                    ),
                    StatusFilterChip(
                      label: 'Nonaktif',
                      status: EmployeeEmploymentStatus.inactive,
                      filterStatus: _filterStatus,
                      onFilterChanged: _handleFilterChanged,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 18, bottom: 4),
                  child: GawenSectionTitle('Daftar Karyawan'),
                ),
                if (state.listStatus == EmployeeListStatus.failure)
                  GawenRequestError(
                    message: state.listMessage ?? 'Data karyawan gagal dimuat.',
                    onRetry: _reload,
                  ),
                if (initialLoading)
                  const Padding(
                    padding: EdgeInsets.all(GawenSpacing.xl),
                    child: GawenLoading(),
                  )
                else ...[
                  if (employees.isEmpty)
                    GawenEmptyState(
                      icon:
                          state.search.isNotEmpty || state.filterStatus != null
                          ? Icons.search_off_rounded
                          : Icons.people_outline_rounded,
                      title:
                          state.search.isNotEmpty || state.filterStatus != null
                          ? 'Karyawan tidak ditemukan'
                          : state.listStatus == EmployeeListStatus.failure
                          ? 'Karyawan tidak dapat dimuat'
                          : 'Belum ada karyawan',
                      description:
                          state.search.isNotEmpty || state.filterStatus != null
                          ? 'Coba ubah kata kunci atau filter pencarian.'
                          : state.listStatus == EmployeeListStatus.failure
                          ? state.listMessage
                          : 'Undang anggota tim untuk mulai bekerja bersama.',
                    )
                  else
                    ...employees.map(
                      (employee) => EmployeeListTile(employee: employee),
                    ),
                  if (state.listStatus == EmployeeListStatus.loadingMore)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: GawenLoading(size: 22, strokeWidth: 2),
                    ),
                  if (state.listStatus == EmployeeListStatus.failure &&
                      employees.isNotEmpty)
                    GawenTextButton(
                      label: 'Coba muat halaman berikutnya lagi',
                      onPressed: () => context.read<EmployeeBloc>().add(
                        const ManagedEmployeesLoadMoreRequested(),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
