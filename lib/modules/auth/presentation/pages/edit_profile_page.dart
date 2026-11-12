import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/app_bar.dart';
import 'package:frontend/core/widgets/gawen_toast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_failure.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gawen_avatar.dart';
import '../../../../core/widgets/gawen_button.dart';
import '../../../../core/widgets/gawen_page.dart';
import '../../../../core/widgets/gawen_text_field.dart';
import '../bloc/auth_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _photoProfile = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _selectedAvatarPath;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    _name.text = user?.name ?? '';
    _email.text = user?.email ?? '';
    _phone.text = _digitsOnly(user?.phone);
    _photoProfile.text = user?.photoProfile ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _photoProfile.dispose();
    super.dispose();
  }

  String _digitsOnly(String? value) {
    var digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('62')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits;
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Nama wajib diisi.';
    if (name.length > 120) return 'Nama maksimal 120 karakter.';
    return null;
  }

  String? _validatePhone(String? value) {
    final digits = _digitsOnly(value);
    if (digits.isNotEmpty &&
        !RegExp(
          r'^(?:[2-7]\d{7,11}|8[1-9]\d{6,10}|9\d{7,11})$',
        ).hasMatch(digits)) {
      return 'Masukkan nomor 8–12 digit tanpa awalan 0.';
    }
    return null;
  }

  Future<void> _pickAvatar() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) return;
      final extension = image.name.split('.').last.toLowerCase();
      if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(extension)) {
        setState(() => _error = 'Pilih gambar JPEG, PNG, atau WebP.');
        return;
      }
      if (await image.length() > 5 * 1024 * 1024) {
        setState(() => _error = 'Ukuran foto maksimal 5 MB.');
        return;
      }
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: image.path,
        maxWidth: 1024,
        maxHeight: 1024,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Atur foto profil',
            toolbarColor: GawenColors.primary,
            toolbarWidgetColor: Colors.white,
            cropStyle: CropStyle.circle,
            initAspectRatio: CropAspectRatioPreset.square,
            hideBottomControls: true,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
          IOSUiSettings(
            title: 'Atur foto profil',
            doneButtonTitle: 'Simpan',
            cancelButtonTitle: 'Batal',
            cropStyle: CropStyle.circle,
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
        ],
      );
      if (croppedImage == null || !mounted) return;
      setState(() {
        _error = null;
        _selectedAvatarPath = croppedImage.path;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Foto tidak dapat dibuka. Coba pilih gambar lain.',
        );
      }
    }
  }

  Future<AuthState> _dispatchAndWait(AuthBloc bloc, AuthEvent event) {
    final result = bloc.stream.firstWhere(
      (state) =>
          state.status == AuthStatus.authenticated ||
          state.status == AuthStatus.failure,
    );
    bloc.add(event);
    return result;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<AuthBloc>();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final digits = _digitsOnly(_phone.text);
      final profileState = await _dispatchAndWait(
        bloc,
        ProfileUpdateRequested(
          name: _name.text.trim(),
          phone: digits.isEmpty ? null : '+62$digits',
        ),
      );
      if (profileState.status != AuthStatus.authenticated ||
          profileState.message != 'Profil berhasil diperbarui.') {
        throw StateError(profileState.message ?? 'Profil gagal diperbarui.');
      }

      if (_selectedAvatarPath != null) {
        final avatarState = await _dispatchAndWait(
          bloc,
          AvatarUploadRequested(_selectedAvatarPath!),
        );
        if (avatarState.status != AuthStatus.authenticated ||
            avatarState.message != null) {
          throw StateError(
            avatarState.message ?? 'Foto profil gagal diunggah.',
          );
        }
      }

      if (!mounted) return;
      GawenToast.success(context, message: 'Profil berhasil diperbarui.');
      Navigator.of(context).pop();
    } on StateError catch (error) {
      if (mounted) {
        GawenToast.error(context, message: friendlyErrorMessage(error.message));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => GawenPage(
    appBar: GawenAppBar(
      title: 'Edit Profil',
      isLeadingEnabled: true,
      leadingWidth: 60.0,
    ),
    scrollable: false,
    child: Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Center(
            child: InkWell(
              onTap: _saving ? null : _pickAvatar,
              customBorder: const CircleBorder(),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: GawenColors.primarySoft,
                    child: ClipOval(
                      child: _selectedAvatarPath != null
                          ? Image.file(
                              File(_selectedAvatarPath!),
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            )
                          : GawenAvatar(imageUrl: _photoProfile.text, size: 96),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: GawenColors.primary,
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Ketuk foto untuk mengganti',
              style: TextStyle(color: GawenColors.muted),
            ),
          ),
          const SizedBox(height: 16),
          GawenTextField(
            controller: _name,
            label: 'Nama lengkap *',
            hint: 'Nama lengkap',
            validator: _validateName,
            textCapitalization: TextCapitalization.words,
          ),
          GawenTextField(
            controller: _email,
            label: 'Email',
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
            enabled: false,
          ),
          GawenTextField(
            controller: _phone,
            label: 'Nomor telepon *',
            hint: '81234567890',
            keyboardType: TextInputType.phone,
            indonesianPhone: true,
            validator: _validatePhone,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
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
}
