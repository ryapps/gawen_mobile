import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gawen_widgets.dart';

class JoinCodeCard extends StatelessWidget {
  const JoinCodeCard({
    required this.code,
    required this.loading,
    required this.rotating,
    required this.message,
    required this.onRetry,
    required this.onCopy,
    required this.onShare,
    required this.onGenerate,
    super.key,
  });

  final String? code;
  final bool loading;
  final bool rotating;
  final String? message;
  final VoidCallback onRetry;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GawenColors.border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kode Bergabung',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 7),
        const Text(
          'Bagikan kode ini kepada karyawan agar mereka dapat mengajukan permintaan bergabung.',
          style: TextStyle(color: GawenColors.muted, height: 1.4),
        ),
        const SizedBox(height: 16),
        if (loading)
          const Padding(padding: EdgeInsets.all(12), child: GawenLoading())
        else if (code != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: GawenColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    code!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 21,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Salin kode',
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_outlined),
                ),
              ],
            ),
          )
        else if (message != null)
          GawenRequestError(message: message!)
        else
          const GawenRequestError(
            message:
                'Kode aktif tidak dapat ditampilkan di perangkat ini. Generate kode baru untuk menggantikan kode lama.',
          ),
        if (message != null && code != null) ...[
          const SizedBox(height: 10),
          Text(
            message!,
            style: const TextStyle(color: GawenColors.muted, fontSize: 12),
          ),
        ],
        if (code != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GawenOutlinedButton(
                  label: 'Salin Kode',
                  onPressed: onCopy,
                  icon: Icons.copy_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GawenPrimaryButton(
                  label: 'Bagikan',
                  onPressed: onShare,
                  icon: Icons.share_outlined,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        if (code == null && !loading)
          SizedBox(
            width: double.infinity,
            child: GawenPrimaryButton(
              label: 'Buat Kode Bergabung',
              onPressed: onGenerate,
              icon: Icons.key_outlined,
              isLoading: rotating,
            ),
          )
        else if (code != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: rotating ? null : onGenerate,
              icon: rotating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, color: GawenColors.error),
              label: const Text(
                'Generate Ulang Kode',
                style: TextStyle(color: GawenColors.error),
              ),
            ),
          ),
        if (message != null && code == null && !loading)
          Align(
            alignment: Alignment.center,
            child: GawenTextButton(
              label: 'Coba muat ulang',
              onPressed: onRetry,
            ),
          ),
      ],
    ),
  );
}
