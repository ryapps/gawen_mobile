import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TeamIllustration extends StatelessWidget {
  const TeamIllustration({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: compact ? 230 : 280,
    height: compact ? 230 : 280,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: compact ? 210 : 260,
          height: compact ? 210 : 260,
          decoration: const BoxDecoration(
            color: GawenColors.primarySoft,
            shape: BoxShape.circle,
          ),
        ),
        Positioned(
          top: compact ? 39 : 45,
          child: Container(
            width: compact ? 144 : 176,
            height: compact ? 90 : 108,
            padding: const EdgeInsets.only(top: 23),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: GawenColors.border),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A214B36),
                  blurRadius: 25,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 19,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: GawenColors.primarySoft,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'BUKA',
                    style: TextStyle(
                      color: GawenColors.primary,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [_ShopWindow(), _ShopWindow(), _ShopWindow()],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: compact ? 26 : 30,
          left: compact ? 28 : 33,
          child: const _TeamPerson(color: Color(0xFF176644)),
        ),
        Positioned(
          bottom: compact ? 20 : 25,
          child: const _TeamPerson(color: Color(0xFFE5A33E), scale: 1.08),
        ),
        Positioned(
          bottom: compact ? 26 : 30,
          right: compact ? 28 : 33,
          child: const _TeamPerson(color: Color(0xFF3478D4)),
        ),
        Positioned(
          top: compact ? 38 : 42,
          right: compact ? 29 : 30,
          child: Container(
            width: 33,
            height: 33,
            decoration: const BoxDecoration(
              color: GawenColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 17,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ShopWindow extends StatelessWidget {
  const _ShopWindow();

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 25,
    decoration: const BoxDecoration(
      border: Border(
        top: BorderSide(color: Color(0xFFD8E4DC), width: 3),
        left: BorderSide(color: Color(0xFFD8E4DC), width: 3),
        right: BorderSide(color: Color(0xFFD8E4DC), width: 3),
      ),
    ),
  );
}

class _TeamPerson extends StatelessWidget {
  const _TeamPerson({required this.color, this.scale = 1});

  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) => Transform.scale(
    scale: scale,
    alignment: Alignment.bottomCenter,
    child: SizedBox(
      width: 58,
      height: 95,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 58,
            height: 65,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(28).copyWith(
                bottomLeft: const Radius.circular(12),
                bottomRight: const Radius.circular(12),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFE7AD74),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
