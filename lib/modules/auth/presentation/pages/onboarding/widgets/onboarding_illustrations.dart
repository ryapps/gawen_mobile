import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';

class ScheduleIllustration extends StatelessWidget {
  const ScheduleIllustration({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 280,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GawenColors.border),
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1F225338),
          blurRadius: 35,
          offset: Offset(0, 15),
        ),
      ],
    ),
    child: const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_month, color: GawenColors.primary),
            SizedBox(width: 9),
            Text(
              'Jadwal Minggu Ini',
              style: TextStyle(fontWeight: FontWeight.w700, color: GawenColors.primary),
            ),
          ],
        ),
        SizedBox(height: 15),
        _Shift(name: 'Rina', shift: 'Pagi', color: GawenColors.primary),
        _Shift(name: 'Agus', shift: 'Siang', color: GawenColors.warning),
        _Shift(name: 'Dewi', shift: 'Pagi', color: GawenColors.primary),
      ],
    ),
  );
}

class _Shift extends StatelessWidget {
  const _Shift({required this.name, required this.shift, required this.color});

  final String name;
  final String shift;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    height: 46,
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: GawenColors.border)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: name == 'Dewi' ? Colors.blue : color,
          child: Text(
            name[0],
            style: const TextStyle(color:Colors.white, fontSize: 10),
          ),
        ),
        const SizedBox(width: 9),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withOpacity(0.1),
          ),
          child: Text(
            shift,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

class InsightIllustration extends StatelessWidget {
  const InsightIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background circle
          Container(
            width: 272,
            height: 272,
            decoration: const BoxDecoration(
              color: GawenColors.primarySoft,
              shape: BoxShape.circle,
            ),
          ),

          // Attendance card
          Positioned(
            top: 86,
            left: 13,
            right: 13,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: GawenColors.border.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A214B36),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Attendance icon container
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: GawenColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.access_time_rounded,
                      color: GawenColors.primary,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 11),

                  // Attendance information
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Absensi',
                          style: TextStyle(
                            color: GawenColors.muted,
                            fontSize: 9,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tercatat rapi',
                          style: TextStyle(
                            color: GawenColors.text,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Success indicator
                  const Icon(
                    Icons.check_rounded,
                    color: GawenColors.primary,
                    size: 21,
                  ),
                ],
              ),
            ),
          ),

          // Kasbon card
          Positioned(
            top: 165,
            left: 23,
            child: Transform.rotate(
              angle: -0.10,
              child: _InsightMiniCard(
                icon: Icons.business_center_outlined,
                label: 'Kasbon',
                color: GawenColors.primary,
              ),
            ),
          ),

          // Salary information card
          Positioned(
            top: 165,
            right: 23,
            child: Transform.rotate(
              angle: 0.10,
              child: _InsightMiniCard(
                icon: Icons.verified_user_outlined,
                label: 'Informasi gaji',
                color: const Color(0xFF4388E8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightMiniCard extends StatelessWidget {
  const _InsightMiniCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 68,
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: GawenColors.border.withOpacity(0.5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14214B36),
            blurRadius: 20,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 19,
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

