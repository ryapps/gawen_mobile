import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum GawenToastType { success, warning, error, info }

class GawenToast {
  GawenToast._();

  static _ActiveToast? _activeToast;

  static void success(
    BuildContext context, {
    String title = 'Berhasil',
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) => _show(
    context,
    type: GawenToastType.success,
    title: title,
    message: message,
    duration: duration,
  );

  static void warning(
    BuildContext context, {
    String title = 'Perhatian',
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) => _show(
    context,
    type: GawenToastType.warning,
    title: title,
    message: message,
    duration: duration,
  );

  static void error(
    BuildContext context, {
    String title = 'Terjadi Kesalahan',
    required String message,
    Duration duration = const Duration(seconds: 5),
  }) => _show(
    context,
    type: GawenToastType.error,
    title: title,
    message: message,
    duration: duration,
  );

  static void info(
    BuildContext context, {
    String title = 'Informasi',
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) => _show(
    context,
    type: GawenToastType.info,
    title: title,
    message: message,
    duration: duration,
  );

  static void _show(
    BuildContext context, {
    required GawenToastType type,
    required String title,
    required String message,
    required Duration duration,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    _activeToast?._removeImmediately();

    final visible = ValueNotifier(false);
    late final _ActiveToast toast;
    final entry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        type: type,
        title: title,
        message: message,
        visible: visible,
        onClose: () => _dismiss(toast),
      ),
    );
    toast = _ActiveToast(entry: entry, visible: visible);
    _activeToast = toast;
    overlay.insert(entry);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (identical(_activeToast, toast)) visible.value = true;
    });
    toast.dismissTimer = Timer(duration, () => _dismiss(toast));
  }

  static void _dismiss(_ActiveToast toast) {
    if (!identical(_activeToast, toast)) return;
    toast.dismissTimer?.cancel();
    toast.visible.value = false;
    toast.exitTimer = Timer(const Duration(milliseconds: 220), () {
      if (!identical(_activeToast, toast)) return;
      _activeToast = null;
      toast._removeImmediately();
    });
  }
}

class _ActiveToast {
  _ActiveToast({required this.entry, required this.visible});

  final OverlayEntry entry;
  final ValueNotifier<bool> visible;
  Timer? dismissTimer;
  Timer? exitTimer;

  void _removeImmediately() {
    dismissTimer?.cancel();
    exitTimer?.cancel();
    if (entry.mounted) entry.remove();
    entry.dispose();
  }
}

class _ToastOverlay extends StatelessWidget {
  const _ToastOverlay({
    required this.type,
    required this.title,
    required this.message,
    required this.visible,
    required this.onClose,
  });

  final GawenToastType type;
  final String title;
  final String message;
  final ValueListenable<bool> visible;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Positioned(
    top: 8,
    left: 16,
    right: 16,
    child: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ValueListenableBuilder<bool>(
            valueListenable: visible,
            builder: (context, isVisible, child) => AnimatedSlide(
              offset: isVisible ? Offset.zero : const Offset(0, -0.25),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: isVisible ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: child,
              ),
            ),
            child: _ToastCard(
              type: type,
              title: title,
              message: message,
              onClose: onClose,
            ),
          ),
        ),
      ),
    ),
  );
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({
    required this.type,
    required this.title,
    required this.message,
    required this.onClose,
  });

  final GawenToastType type;
  final String title;
  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final (background, accent, icon) = switch (type) {
      GawenToastType.success => (
        GawenColors.successSoft,
        GawenColors.primary,
        Icons.check_rounded,
      ),
      GawenToastType.warning => (
        GawenColors.warningSoft,
        GawenColors.warning,
        Icons.priority_high_rounded,
      ),
      GawenToastType.error => (
        GawenColors.errorSoft,
        GawenColors.error,
        Icons.close_rounded,
      ),
      GawenToastType.info => (
        GawenColors.toastInfoSoft,
        GawenColors.toastInfo,
        Icons.info_outline_rounded,
      ),
    };

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(GawenRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: Icon(icon, size: 21, color: Colors.white),
            ),
            const SizedBox(width: GawenSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GawenTextStyles.label.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GawenTextStyles.caption.copyWith(
                      color: GawenColors.text,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Tutup notifikasi',
              visualDensity: VisualDensity.compact,
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, size: 20),
              color: GawenColors.text,
            ),
          ],
        ),
      ),
    );
  }
}
