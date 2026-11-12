import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/app_bar.dart';
import '../../../../core/widgets/gawen_toast.dart';
import '../../../../core/widgets/gawen_button.dart';
import '../../../../core/widgets/gawen_loading.dart';
import '../../../../core/widgets/gawen_text_field.dart';
import '../../../../core/widgets/request_error.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/employee_bloc.dart';

class EditEmployeePage extends StatefulWidget {
  const EditEmployeePage({required this.employeeId, super.key});

  final String employeeId;

  @override
  State<EditEmployeePage> createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final _positionController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final employee = context.read<EmployeeBloc>().state.selectedEmployee;
    if (employee?.id == widget.employeeId) {
      _positionController.text = employee?.position ?? '';
      _initialized = true;
    } else {
      context.read<EmployeeBloc>().add(
        ManagedEmployeeDetailRequested(widget.employeeId),
      );
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  String? _validatePosition(String? value) {
    if ((value?.trim().length ?? 0) > 120) {
      return 'Jabatan maksimal 120 karakter.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!context.watch<AuthBloc>().state.isOwner) {
      return const Scaffold(
        body: Center(child: Text('Halaman ini hanya untuk pemilik usaha.')),
      );
    }
    return BlocConsumer<EmployeeBloc, EmployeeState>(
      listenWhen: (previous, current) =>
          previous.selectedEmployee?.id != current.selectedEmployee?.id ||
          previous.status != current.status ||
          previous.detailStatus != current.detailStatus,
      listener: (context, state) {
        final employee = state.selectedEmployee;
        if (!_initialized &&
            employee?.id == widget.employeeId &&
            state.detailStatus == EmployeeDetailStatus.ready) {
          _positionController.text = employee?.position ?? '';
          _initialized = true;
        }
        if (state.status == EmployeeStatus.failure && _saving) {
          _saving = false;
          GawenToast.error(
            context,
            message: state.message ?? 'Informasi pekerjaan gagal disimpan.',
          );
        } else if (state.status == EmployeeStatus.ready &&
            state.message == 'Informasi pekerjaan diperbarui.') {
          _saving = false;
          GawenToast.success(
            context,
            message: 'Informasi pekerjaan diperbarui.',
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final employee = state.selectedEmployee?.id == widget.employeeId
            ? state.selectedEmployee
            : null;
        final loading =
            state.detailStatus == EmployeeDetailStatus.loading &&
            employee == null;
        return Scaffold(
          appBar: GawenAppBar(
            title: 'Edit Informasi Pekerjaan',
            isLeadingEnabled: true,
          ),
          body: loading
              ? const GawenLoading()
              : employee == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GawenRequestError(
                          message:
                              state.detailMessage ??
                              'Informasi karyawan tidak tersedia.',
                        ),
                        TextButton(
                          onPressed: () => context.read<EmployeeBloc>().add(
                            ManagedEmployeeDetailRequested(widget.employeeId),
                          ),
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(22),
                    children: [
                      GawenTextField(
                        controller: _positionController,
                        label: 'Jabatan',
                        hint: 'Contoh: Kasir',
                        icon: Icons.badge_outlined,
                        maxLength: 120,
                        textCapitalization: TextCapitalization.words,
                        validator: _validatePosition,
                      ),
                      const SizedBox(height: 24),
                      GawenPrimaryButton(
                        label: 'Simpan perubahan',
                        onPressed: _save,
                        isLoading: _saving,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    context.read<EmployeeBloc>().add(
      ManagedEmployeePositionUpdateRequested(
        employeeId: widget.employeeId,
        position: _positionController.text.trim().isEmpty
            ? null
            : _positionController.text.trim(),
      ),
    );
  }
}
