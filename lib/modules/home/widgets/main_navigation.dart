import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';

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
    final selectedIndex = switch (currentPath) {
      AppRoutes.home => 0,
      AppRoutes.employees || AppRoutes.team => 1,
      AppRoutes.schedule => 2,
      _ => 3,
    };

    final paths = [
      AppRoutes.home,
      isOwner ? AppRoutes.employees : AppRoutes.team,
      AppRoutes.schedule,
      AppRoutes.more,
    ];

    const labels = ['Home', 'Karyawan', 'Jadwal', 'Lainnya'];

    const icons = [
      CupertinoIcons.home,
      CupertinoIcons.person_2,
      CupertinoIcons.calendar,
      CupertinoIcons.ellipsis_circle,
    ];

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: const BoxDecoration(
          color: GawenColors.background,
          border: Border(top: BorderSide(color: GawenColors.border, width: 1)),
        ),
        child: Row(
          children: List.generate(paths.length, (index) {
            final isSelected = selectedIndex == index;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Material(
                  color: isSelected
                      ? const Color(0xFFE5F5EC)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (!isSelected) {
                        context.pushReplacement(paths[index]);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icons[index],
                            color: isSelected
                                ? GawenColors.primary
                                : const Color(0xFF68756C),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            labels[index],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? GawenColors.primary
                                  : const Color(0xFF68756C),
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
