import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/gawen_widgets.dart';
import 'package:frontend/modules/invitation/domain/entities/invitation_entity.dart';

class InvitationCard extends StatelessWidget {
  const InvitationCard({
    super.key,
    required this.invitation,
    required this.onAccept,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final InvitationEntity invitation;
  final VoidCallback onAccept;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final expiry = MaterialLocalizations.of(
      context,
    ).formatMediumDate(invitation.expiresAt.toLocal());
    return Padding(
      padding: const EdgeInsets.only(bottom: GawenSpacing.md),
      child: GawenCard(
        padding: const EdgeInsets.all(GawenSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: GawenColors.primarySoft,
                    borderRadius: BorderRadius.circular(GawenRadius.md),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: GawenColors.primary,
                  ),
                ),
                const SizedBox(width: GawenSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GawenSectionTitle(
                        invitation.organizationName ?? 'Tempat kerja',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: GawenSpacing.xs),
                      const GawenCaption('Undangan untuk bergabung'),
                      const SizedBox(height: GawenSpacing.xs),
                      GawenCaption('Berlaku hingga $expiry'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: GawenSpacing.md),
            SizedBox(
              width: double.infinity,
              child: GawenPrimaryButton(
                label: 'Terima Undangan',
                onPressed: onAccept,
                isLoading: isLoading,
                enabled: isEnabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
