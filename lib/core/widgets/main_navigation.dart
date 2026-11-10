import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/route_names.dart';
import '../theme/app_theme.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({
    super.key,
    required this.isOwner,
    required this.currentPath,
  });

  final bool isOwner;
  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final items = [
      (path: AppRoutes.home, label: 'Home', icon: CupertinoIcons.home),
      if (isOwner)
        (
          path: AppRoutes.employees,
          label: 'Karyawan',
          icon: CupertinoIcons.person_2,
        ),
      (
        path: AppRoutes.schedule,
        label: 'Jadwal',
        icon: CupertinoIcons.calendar,
      ),
      (
        path: AppRoutes.more,
        label: 'Lainnya',
        icon: CupertinoIcons.ellipsis_circle,
      ),
    ];
    final selectedPath = currentPath == AppRoutes.team
        ? AppRoutes.home
        : currentPath;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: const BoxDecoration(
          color: GawenColors.background,
          border: Border(top: BorderSide(color: GawenColors.border, width: 1)),
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = selectedPath == item.path;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: GawenSpacing.xs,
                ),
                child: Material(
                  color: isSelected
                      ? GawenColors.primarySoft
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(GawenRadius.lg),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(GawenRadius.lg),
                    onTap: () {
                      if (!isSelected) {
                        context.pushReplacement(item.path);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected
                                ? GawenColors.primary
                                : GawenColors.muted,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? GawenColors.primary
                                  : GawenColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
